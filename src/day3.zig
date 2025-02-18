const std = @import("std");
const utils = @import("utils.zig");

pub const Part = enum {
    one,
    two,
};

pub fn solveMultiplication(input_file: []const u8, part: Part) !u32 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        std.debug.assert(gpa.deinit() == .ok);
    }
    const allocator = gpa.allocator();

    const file = try utils.openFile(input_file);
    defer file.close();

    const source = try file.reader().readAllAlloc(allocator, std.math.maxInt(usize));
    defer allocator.free(source);

    var scanner = Scanner.init(source);

    var multiplier = Multiplier.init();
    defer multiplier.clear();

    var result: u32 = 0;
    var do: bool = true;
    while (!scanner.isAtEnd()) {
        const token = scanner.scanToken();
        if (token.ty == .KEYWORD_DO) {
            do = true;
        } else if (token.ty == .KEYWORD_DONT) {
            do = false;
        }

        if (multiplier.needs() != token.ty) {
            multiplier.clear();
        }
        if (multiplier.needs() == token.ty) {
            switch (token.ty) {
                .KEYWORD_MUL => {
                    multiplier.hasMul = true;
                },
                .LEFT_PAREN => {
                    multiplier.hasLeftParen = true;
                },
                .NUM => {
                    if (multiplier.num1 == null) {
                        try multiplier.setNum1(token.lexeme);
                    } else if (multiplier.num2 == null) {
                        try multiplier.setNum2(token.lexeme);
                    }
                },
                .COMMA => {
                    multiplier.hasComma = true;
                },
                .RIGHT_PAREN => {
                    multiplier.hasRightParen = true;
                },
                else => {
                    multiplier.clear();
                },
            }
        } else {
            // got a token that we don't need, clear the multiplier and start over
            multiplier.clear();
        }

        if (multiplier.isValid()) {
            if (do or part == .one) result += multiplier.num1.? * multiplier.num2.?;
            multiplier.clear();
        }
    }

    return result;
}

const Multiplier = struct {
    hasMul: bool,
    hasLeftParen: bool,
    num1: ?u32,
    hasComma: bool,
    hasRightParen: bool,
    num2: ?u32,

    pub fn init() Multiplier {
        return Multiplier{
            .hasMul = false,
            .hasLeftParen = false,
            .hasRightParen = false,
            .hasComma = false,
            .num1 = null,
            .num2 = null,
        };
    }

    pub fn needs(self: *Multiplier) TokenType {
        if (!self.hasMul) {
            return TokenType.KEYWORD_MUL;
        } else if (!self.hasLeftParen) {
            return TokenType.LEFT_PAREN;
        } else if (self.num1 == null) {
            return TokenType.NUM;
        } else if (!self.hasComma) {
            return TokenType.COMMA;
        } else if (self.num2 == null) {
            return TokenType.NUM;
        } else if (!self.hasRightParen) {
            return TokenType.RIGHT_PAREN;
        }
        return TokenType.ILLEGAL;
    }

    pub fn clear(self: *Multiplier) void {
        self.hasMul = false;
        self.hasLeftParen = false;
        self.hasRightParen = false;
        self.hasComma = false;
        self.num1 = null;
        self.num2 = null;
    }

    pub fn isValid(self: *Multiplier) bool {
        return self.hasMul and self.hasLeftParen and self.hasRightParen and self.hasComma and self.num1 != null and self.num2 != null;
    }

    pub fn setNum1(self: *Multiplier, numSt: []const u8) !void {
        self.num1 = try std.fmt.parseInt(u32, numSt, 10);
    }

    pub fn setNum2(self: *Multiplier, numSt: []const u8) !void {
        self.num2 = try std.fmt.parseInt(u32, numSt, 10);
    }
};

const Scanner = struct {
    source: []const u8,
    start: usize,
    current: usize,
    line: usize,

    end: usize,

    pub fn init(source: []const u8) Scanner {
        return Scanner{
            .source = source,
            .start = 0,
            .current = 0,
            .line = 1,
            .end = source.len,
        };
    }

    pub fn scanToken(self: *Scanner) Token {
        self.start = self.current;
        const c = self.advance();

        switch (c) {
            '(' => return Token{
                .ty = TokenType.LEFT_PAREN,
                .lexeme = self.source[self.start..self.current],
                .loc = self.start,
            },
            ')' => return Token{
                .ty = TokenType.RIGHT_PAREN,
                .lexeme = self.source[self.start..self.current],
                .loc = self.start,
            },
            ',' => return Token{
                .ty = TokenType.COMMA,
                .lexeme = self.source[self.start..self.current],
                .loc = self.start,
            },
            '0'...'9' => return try self.integer(),
            'm' => {
                // std.debug.print("found m, checking for mul\n", .{});
                if (self.matchNext("mul")) {
                    return self.keyword("mul", TokenType.KEYWORD_MUL);
                } else {
                    return Token{
                        .ty = TokenType.ILLEGAL,
                        .lexeme = self.source[self.start..self.current],
                        .loc = self.start,
                    };
                }
            },
            'd' => {
                if (self.matchNext("do()")) {
                    return self.keyword("do()", TokenType.KEYWORD_DO);
                } else if (self.matchNext("don't()")) {
                    return self.keyword("don't", TokenType.KEYWORD_DONT);
                } else {
                    return Token{
                        .ty = TokenType.ILLEGAL,
                        .lexeme = self.source[self.start..self.current],
                        .loc = self.start,
                    };
                }
            },
            ' ' => {
                return Token{
                    .ty = TokenType.ILLEGAL,
                    .lexeme = self.source[self.start..self.current],
                    .loc = self.start,
                };
            },
            else => {
                return Token{
                    .ty = TokenType.ILLEGAL,
                    .lexeme = self.source[self.start..self.current],
                    .loc = self.start,
                };
            },
        }
    }

    pub fn peek(self: *Scanner) u8 {
        if (self.isAtEnd()) return 0;
        return self.source[self.current];
    }

    pub fn peekNext(self: *Scanner) u8 {
        if (self.current + 1 >= self.end) return 0;
        return self.source[self.current + 1];
    }

    pub fn matchNext(self: *Scanner, expected: []const u8) bool {
        if (self.isAtEnd() or self.start + expected.len >= self.end) return false;
        return std.mem.eql(u8, self.source[self.start .. self.start + expected.len], expected);
    }

    pub fn advance(self: *Scanner) u8 {
        if (self.isAtEnd()) return 0;
        self.current += 1;
        return self.source[self.current - 1];
    }

    pub fn integer(self: *Scanner) !Token {
        while (std.ascii.isDigit(self.peek())) {
            _ = self.advance();
        }
        return Token{
            .ty = TokenType.NUM,
            .lexeme = self.source[self.start..self.current],
            .loc = self.start,
        };
    }

    pub fn keywordMul(self: *Scanner) Token {
        var i: usize = 0;
        while (std.ascii.isAlphabetic(self.peek()) and i < 3) {
            _ = self.advance();
            i += 1;
        }
        if (i == 2) {
            return Token{
                .ty = TokenType.KEYWORD_MUL,
                .lexeme = self.source[self.start..self.current],
                .loc = self.start,
            };
        } else {
            return Token{
                .ty = TokenType.ILLEGAL,
                .lexeme = self.source[self.start..self.current],
                .loc = self.start,
            };
        }
    }

    pub fn keyword(self: *Scanner, kw: []const u8, ty: TokenType) Token {
        for (1..kw.len) |i| {
            if (self.peek() != kw[i]) {
                return Token{
                    .ty = TokenType.ILLEGAL,
                    .lexeme = self.source[self.start..self.current],
                    .loc = self.start,
                };
            }
            _ = self.advance();
        }
        return Token{
            .ty = ty,
            .lexeme = self.source[self.start..self.current],
            .loc = self.start,
        };
    }

    pub fn isAtEnd(self: *Scanner) bool {
        return self.current >= self.end;
    }
};

const Token = struct {
    ty: TokenType,
    lexeme: []const u8,
    loc: usize,
};

const TokenType = enum {
    KEYWORD_MUL, // "mul"
    LEFT_PAREN,
    NUM,
    COMMA,
    RIGHT_PAREN,
    ILLEGAL,
    KEYWORD_DO, // do
    KEYWORD_DONT, // don't
};
