LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_ARITH.ALL;
USE IEEE.std_logic_UNSIGNED.ALL;

ENTITY MAIN IS
    PORT (
        CLOCK : IN STD_LOGIC;
        HSYNC : OUT STD_LOGIC;
        VSYNC : OUT STD_LOGIC;
        RED : OUT STD_LOGIC;
        GREEN : OUT STD_LOGIC;
        BLUE : OUT STD_LOGIC;

        P1_DOWN : IN STD_LOGIC;
        P1_READY : IN STD_LOGIC;
        P1_UP : IN STD_LOGIC;
        P2_DOWN : IN STD_LOGIC;
        P2_READY : IN STD_LOGIC;
        P2_UP : IN STD_LOGIC;

        P1_SCORE : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        P2_SCORE : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
    );
END MAIN;

ARCHITECTURE Behavioral OF MAIN IS
    SIGNAL x : NATURAL RANGE 0 TO 635 := 0;
    SIGNAL y : NATURAL RANGE 0 TO 525 := 0;

    CONSTANT X_VISIBLE_AREA : NATURAL := 508;
    CONSTANT X_FRONT_PORCH : NATURAL := 13;
    CONSTANT X_SYNC_PULSE : NATURAL := 76;
    CONSTANT X_BACK_PORCH : NATURAL := 38;
    CONSTANT X_WHOLE_LINE : NATURAL := 635;

    CONSTANT Y_VISIBLE_AREA : NATURAL := 480;
    CONSTANT Y_FRONT_PORCH : NATURAL := 10;
    CONSTANT Y_SYNC_PULSE : NATURAL := 2;
    CONSTANT Y_BACK_PORCH : NATURAL := 33;
    CONSTANT Y_WHOLE_FRAME : NATURAL := 525;

    CONSTANT RIGHT_BORDER : NATURAL := X_WHOLE_LINE - X_FRONT_PORCH + 2;
    CONSTANT LEFT_BORDER : NATURAL := X_SYNC_PULSE + X_BACK_PORCH + 1;
    CONSTANT DOWN_BORDER : NATURAL := Y_WHOLE_FRAME - Y_FRONT_PORCH + 1;
    CONSTANT UP_BORDER : NATURAL := Y_SYNC_PULSE + Y_BACK_PORCH + 1;
    CONSTANT GAME_WIDTH : NATURAL := RIGHT_BORDER - LEFT_BORDER;
    CONSTANT GAME_HEIGHT : NATURAL := DOWN_BORDER - UP_BORDER;

    TYPE StateType IS (INIT, IDLE, PLAY, WIN);
    SIGNAL CurrentState : StateType := INIT;

    TYPE Rectangle IS RECORD
        x : INTEGER RANGE 0 TO GAME_WIDTH;
        y : INTEGER RANGE 0 TO GAME_HEIGHT;
        speedX : INTEGER RANGE -5 TO 5;
        speedY : INTEGER RANGE -5 TO 5;
        width : NATURAL RANGE 0 TO 100;
        height : NATURAL RANGE 0 TO 100;
        flag : BOOLEAN;
    END RECORD;

    CONSTANT font : STD_LOGIC_VECTOR(0 TO 4607) := "000000000000000000000000000000000000000000000000001000001000001000001000000000001000000000000000010100010100000000000000000000000000000000000000000000010100111110010100111110010100000000000000001000011100101000011100001010011100001000000000000000110010110100001000010110100110000000000000000000010000101000011010100100011010000000000000001000001000000000000000000000000000000000000000001100010000010000010000010000010000001100000000011000000100000100000100000100000100011000000000000000000000010100001000010100000000000000000000000000000000001000011100001000000000000000000000000000000000000000000000000000001000001000000000000000000000000000011100000000000000000000000000000000000000000000000000000000001000000000000000000100000100001000001000010000010000000000000000000000001000010100010100010100001000000000000000000000001000011000001000001000011100000000000000000000011000000100001000010000011100000000000000000000011000000100001000000100011000000000000000000000010000100000101000111100001000000000000000000000011100010000011000000100011000000000000000000000001100010000011000010100001000000000000000000000011100000100000100001000001000000000000000000000001000010100001000010100001000000000000000000000001000010100001100000100011000000000000000000000000000000000001000000000001000000000000000000000000000000000001000000000001000001000000000000000000000001000010000001000000000000000000000000000000000011100000000011100000000000000000000000000000000001000000100001000000000000000000000000000011000000100001000000000001000000000000000011100100010101110101100100000011110000000000000000000011000100100111100100100100100000000000000000000111000100100111000100100111000000000000000000000011100100000100000100000011100000000000000000000111000100100100100100100111000000000000000000000111100100000110000100000111100000000000000000000111100100000111000100000100000000000000000000000011100100000101100100010011100000000000000000000100100100100111100100100100100000000000000000000011100001000001000001000011100000000000000000000111100000100000100000100000100100100011000000000100100100100111000100100100100000000000000000000100000100000100000100000111100000000000000000000100010110110101010100010100010000000000000000000100010110010101010100110100010000000000000000000011000100100100100100100011000000000000000000000111000100100111000100000100000000000000000000000011000100100100100101100011100000010000000000000111000100100111000100100100100000000000000000000011100100000011000000100111000000000000000000000111110001000001000001000001000000000000000000000100100100100100100100100011000000000000000000000100010100010100010010100001000000000000000000000100010100010101010110110100010000000000000000000100010010100001000010100100010000000000000000000100010100010010100001000001000000000000000000000111110000100001000010000111110000000000000011100010000010000010000010000010000011100000000010000010000001000001000000100000100000000000000011100000100000100000100000100000100011100000000001000010100000000000000000000000000000000000000000000000000000000000000000000000000011100000000010000001000000000000000000000000000000000000000000000000000011000100100100100011110000000000000000000100000111000100100100100011000000000000000000000000000011000100000100000011000000000000000000000000100011100100100100100011100000000000000000000000000011000101100110000011100000000000000000000000000001100010000010000011000010000010000000000000000011000100100100100011100000100011000000000100000101000110100100100100100000000000000000000010000000000010000010000001000000000000000000000001000000000001000001000001000001000010000000000100000101100110000101000100100000000000000000000010000010000010000010000001000000000000000000000000000110100101010101010100010000000000000000000000000101000110100100100100100000000000000000000000000011000100100100100011000000000000000000000000000111000100100100100111000100000100000000000000000011100100100100100011100000100000100000000000000001100010000010000010000000000000000000000000000001100011000000100011000000000000000000000010000111000010000010000001000000000000000000000000000100100100100100100011110000000000000000000000000010010010010010100001000000000000000000000000000100010100010101010010100000000000000000000000000010100001000010100100100000000000000000000000000100100100100100100011100000100011000000000000000111100001000010000111100000000000000001100010000001000011000001000010000001100000000001000001000001000001000001000001000001000000000011000000100001000001100001000000100011000000000000000010100101000000000000000000000000000000000000000000000000000000000000000000000000000000000";

BEGIN
    PROCESS (CLOCK)

        IMPURE FUNCTION toInteger(
            s : STD_LOGIC) RETURN NATURAL IS
        BEGIN
            IF s = '1' THEN
                RETURN 1;
            END IF;
            RETURN 0;
        END FUNCTION;

        IMPURE FUNCTION clamp(
            x : INTEGER;
            a : INTEGER;
            b : INTEGER) RETURN NATURAL IS
        BEGIN
            IF x <= a + 1 THEN
                RETURN a + 1;
            END IF;
            IF x >= b THEN
                RETURN b;
            END IF;
            RETURN x;
        END FUNCTION;

        IMPURE FUNCTION intersection(
            a : Rectangle;
            b : Rectangle) RETURN BOOLEAN IS
        BEGIN
            IF a.x > b.x + b.width OR b.x > a.x + a.width OR
                a.y > b.y + b.height OR b.y > a.y + a.height THEN
                RETURN false;
            END IF;
            RETURN true;
        END FUNCTION;

        IMPURE FUNCTION bounce(
            a : Rectangle;
            b : Rectangle) RETURN Rectangle IS
            VARIABLE box : Rectangle;
        BEGIN
            box := a;
            IF intersection(a, b) THEN
                IF a.x <= b.x - a.width OR a.x >= b.x + b.width THEN
                    box.speedX := 0 - box.speedX;
                    box.x := box.x + box.speedX;
                    box.flag := true;
                END IF;
                IF a.y <= b.y - a.height OR a.y >= b.y + b.height THEN
                    box.speedY := 0 - box.speedY;
                    box.y := box.y + box.speedY;
                    box.flag := true;
                END IF;
            END IF;
            RETURN box;
        END FUNCTION;

        PROCEDURE setColor(
            r : STD_LOGIC;
            g : STD_LOGIC;
            b : STD_LOGIC) IS
        BEGIN
            RED <= r;
            GREEN <= g;
            BLUE <= b;
        END PROCEDURE;

        PROCEDURE drawChar(
            xp : NATURAL;
            yp : NATURAL;
            char : STD_LOGIC_VECTOR(0 TO 47)
        ) IS
            VARIABLE xr : NATURAL;
            VARIABLE yr : NATURAL;
            VARIABLE xx : NATURAL;
            VARIABLE yy : NATURAL;
            VARIABLE pixel_index : NATURAL;
        BEGIN
            xx := xp + LEFT_BORDER;
            yy := yp + UP_BORDER;
            xr := x - xx;
            yr := y - yy;
            pixel_index := (yr / 3) * 6 + (xr / 3);
            IF x >= xx AND x < xx + 6 * 3 AND y >= yy AND y < yy + 8 * 3 AND pixel_index >= 0 AND pixel_index < 48 THEN
                IF char(pixel_index) = '1' THEN
                    setColor('1', '1', '1');
                ELSE
                    setColor('1', '1', '1');
                END IF;
            END IF;

        END PROCEDURE;

        PROCEDURE drawWall IS
        BEGIN
            IF x < LEFT_BORDER + 2 THEN
                setColor('1', '1', '1');
            END IF;
            IF x >= RIGHT_BORDER - 2 THEN
                setColor('1', '1', '1');
            END IF;
            IF y < UP_BORDER + 2 THEN
                setColor('1', '1', '1');
            END IF;
            IF y >= DOWN_BORDER - 4 THEN
                setColor('1', '1', '1');
            END IF;
        END PROCEDURE;

        PROCEDURE printChar(
            xp : NATURAL;
            yp : NATURAL;
            ascii : NATURAL
        ) IS
        BEGIN
            drawChar(xp, yp, font((ascii - 32) * 48 TO(ascii - 32) * 48 + 47));
        END PROCEDURE;

        PROCEDURE drawRectangle(
            rect : Rectangle;
            r : STD_LOGIC;
            g : STD_LOGIC;
            b : STD_LOGIC) IS
            VARIABLE x_rel : NATURAL;
            VARIABLE y_rel : NATURAL;
        BEGIN
            x_rel := x - rect.x - LEFT_BORDER;
            y_rel := y - rect.y - UP_BORDER;

            IF x_rel >= 0 AND x_rel < rect.width AND y_rel >= 0 AND y_rel < rect.height THEN
                setColor(r, g, b);
            END IF;
        END PROCEDURE;

        PROCEDURE printScore(
            xp : NATURAL;
            yp : NATURAL;
            score : NATURAL RANGE 0 TO 9) IS
        BEGIN
            CASE score IS
                WHEN 0 =>
                    printChar(xp, yp, 48);
                WHEN 1 =>
                    printChar(xp, yp, 49);
                WHEN 2 =>
                    printChar(xp, yp, 50);
                WHEN 3 =>
                    printChar(xp, yp, 51);
                WHEN 4 =>
                    printChar(xp, yp, 52);
                WHEN 5 =>
                    printChar(xp, yp, 53);
                WHEN 6 =>
                    printChar(xp, yp, 54);
                WHEN 7 =>
                    printChar(xp, yp, 55);
                WHEN 8 =>
                    printChar(xp, yp, 56);
                WHEN 9 =>
                    printChar(xp, yp, 57);
                WHEN OTHERS =>
                    printChar(xp, yp, 48);
            END CASE;
        END PROCEDURE;

        PROCEDURE drawNet IS
            VARIABLE i : INTEGER := 0;
        BEGIN
            WHILE 5 + 6 * i + 4 < GAME_HEIGHT LOOP
                drawRectangle((
                x => GAME_WIDTH / 2,
                y => 5 + 6 * i,
                speedX => 0,
                speedY => 0,
                width => 1,
                height => 2,
                flag => false
                ),
                r => '1',
                g => '1',
                b => '1');
                i := i + 1;
            END LOOP;
        END PROCEDURE;

        PROCEDURE drawWelcome IS
            VARIABLE xLine1 : NATURAL;
            VARIABLE yLine1 : NATURAL;
            VARIABLE xLine2 : NATURAL;
            VARIABLE yLine2 : NATURAL;
        BEGIN
            xLine1 := GAME_WIDTH / 2 - 120;
            yLine1 := GAME_HEIGHT / 2 - 13;

            xLine2 := GAME_WIDTH / 2 - 115;
            yLine2 := GAME_HEIGHT / 2 + 13;

            printChar(xLine1, yLine1, 71);
            printChar(xLine1 + 19, yLine1, 97);
            printChar(xLine1 + 38, yLine1, 108);
            printChar(xLine1 + 57, yLine1, 97);
            printChar(xLine1 + 76, yLine1, 111);
            printChar(xLine1 + 95, yLine1, 110);
            printChar(xLine1 + 114, yLine1, 103);
            printChar(xLine1 + 133, yLine1, 112);
            printChar(xLine1 + 152, yLine1, 111);
            printChar(xLine1 + 171, yLine1, 110);
            printChar(xLine1 + 190, yLine1, 103);
            printChar(xLine1 + 209, yLine1, 112);
            printChar(xLine1 + 228, yLine1, 97);
            printChar(xLine1 + 247, yLine1, 110);
            printChar(xLine1 + 266, yLine1, 103);
            printChar(xLine1 + 285, yLine1, 33);

            printChar(xLine2, yLine2, 80);
            printChar(xLine2 + 19, yLine2, 114);
            printChar(xLine2 + 38, yLine2, 101);
            printChar(xLine2 + 57, yLine2, 115);
            printChar(xLine2 + 76, yLine2, 115);
            printChar(xLine2 + 95, yLine2, 32);
            printChar(xLine2 + 114, yLine2, 98);
            printChar(xLine2 + 133, yLine2, 117);
            printChar(xLine2 + 152, yLine2, 116);
            printChar(xLine2 + 171, yLine2, 116);
            printChar(xLine2 + 190, yLine2, 111);
            printChar(xLine2 + 209, yLine2, 110);
            printChar(xLine2 + 228, yLine2, 32);
            printChar(xLine2 + 247, yLine2, 116);
            printChar(xLine2 + 266, yLine2, 111);
            printChar(xLine2 + 285, yLine2, 32);
            printChar(xLine2 + 304, yLine2, 112);
            printChar(xLine2 + 323, yLine2, 108);
            printChar(xLine2 + 342, yLine2, 97);
            printChar(xLine2 + 361, yLine2, 121);
            printChar(xLine2 + 380, yLine2, 33);

        END PROCEDURE;

        PROCEDURE drawWin(
            p : INTEGER) IS
            VARIABLE xLine : NATURAL;
            VARIABLE yLine : NATURAL;
        BEGIN
            xLine := GAME_WIDTH / 2 - 50;
            yLine := GAME_HEIGHT / 2 - 3;

            IF p = 1 THEN
                printChar(xLine, yLine, 82);
                printChar(xLine + 19, yLine, 101);
                printChar(xLine + 38, yLine, 100);
                printChar(xLine + 57, yLine, 32);
                printChar(xLine + 76, yLine, 119);
                printChar(xLine + 95, yLine, 105);
                printChar(xLine + 114, yLine, 110);
                printChar(xLine + 133, yLine, 33);
            ELSE
                printChar(xLine, yLine, 66);
                printChar(xLine + 19, yLine, 108);
                printChar(xLine + 38, yLine, 117);
                printChar(xLine + 57, yLine, 101);
                printChar(xLine + 76, yLine, 32);
                printChar(xLine + 95, yLine, 119);
                printChar(xLine + 114, yLine, 105);
                printChar(xLine + 133, yLine, 110);
                printChar(xLine + 152, yLine, 33);
            END IF;
        END PROCEDURE;

        PROCEDURE updateScoreboard(
            p1Score : INTEGER;
            p2Score : INTEGER
        ) IS
        BEGIN
            IF (p1Score / 4) MOD 2 = 1 THEN
                P1_SCORE(2) <= '1';
            ELSE
                P1_SCORE(2) <= '0';
            END IF;

            IF (p1Score / 2) MOD 2 = 1 THEN
                P1_SCORE(1) <= '1';
            ELSE
                P1_SCORE(1) <= '0';
            END IF;

            IF p1Score MOD 2 = 1 THEN
                P1_SCORE(0) <= '1';
            ELSE
                P1_SCORE(0) <= '0';
            END IF;

            IF (p2Score / 4) MOD 2 = 1 THEN
                P2_SCORE(2) <= '1';
            ELSE
                P2_SCORE(2) <= '0';
            END IF;

            IF (p2Score / 2) MOD 2 = 1 THEN
                P2_SCORE(1) <= '1';
            ELSE
                P2_SCORE(1) <= '0';
            END IF;

            IF p2Score MOD 2 = 1 THEN
                P2_SCORE(0) <= '1';
            ELSE
                P2_SCORE(0) <= '0';
            END IF;
        END PROCEDURE;

        VARIABLE counter : NATURAL RANGE 0 TO 1000000 := 0;
        VARIABLE p1Score : INTEGER RANGE 0 TO 7 := 0;
        VARIABLE p2Score : INTEGER RANGE 0 TO 7 := 0;
        VARIABLE winner : INTEGER RANGE 0 TO 2 := 0;

        VARIABLE player1 : Rectangle := (
            x => 12,
            y => GAME_HEIGHT / 2,
            speedX => 0,
            speedY => 0,
            width => 4,
            height => 48,
            flag => false
        );

        VARIABLE player2 : Rectangle := (
            x => GAME_WIDTH - 16,
            y => GAME_HEIGHT / 2,
            speedX => 0,
            speedY => 0,
            width => 4,
            height => 48,
            flag => false
        );

        VARIABLE ball : Rectangle := (
            x => 17,
            y => GAME_HEIGHT / 2,
            speedX => 1,
            speedY => 1,
            width => 6,
            height => 6,
            flag => false
        );
    BEGIN

        IF rising_edge(CLOCK) THEN

            setColor('0', '0', '0');

            counter := counter + 1;

            IF counter = 1000000 THEN
                counter := 0;

                CASE CurrentState IS
                
                    WHEN INIT =>

                        drawWelcome;

                        IF P1_READY = '1' OR P2_READY = '1' THEN
                            CurrentState <= IDLE;
                        END IF;

                    WHEN IDLE =>

                        printScore((GAME_WIDTH/2) - 30, 32, p1Score);
                        printScore((GAME_WIDTH/2) + 30, 32, p2Score);

                        drawNet;
                        drawWall;

                        drawRectangle(ball, '1', '1', '0');
                        drawRectangle(player1, '1', '0', '0');
                        drawRectangle(player2, '0', '0', '1');

                        IF P1_READY = '1' OR P2_READY = '1' THEN
                            CurrentState <= PLAY;
                        END IF;

                    WHEN PLAY =>

                        IF ball.y = 1 OR ball.y = GAME_HEIGHT - ball.height THEN
                            ball.speedY := 0 - ball.speedY;
                        END IF;

                        player1.speedY := toInteger(P1_UP) - toInteger(P1_DOWN);
                        player2.speedY := toInteger(P2_UP) - toInteger(P2_DOWN);

                        player1.y := player1.y + player1.speedY;
                        player1.y := clamp(player1.y, 5, GAME_HEIGHT - player1.height - 5);
                        player2.y := player2.y + player2.speedY;
                        player2.y := clamp(player2.y, 5, GAME_HEIGHT - player2.height - 5);

                        ball := bounce(ball, player1);
                        ball := bounce(ball, player2);

                        ball.x := ball.x + ball.speedX;
                        ball.y := ball.y + ball.speedY;

                        ball.x := clamp(ball.x, 0, GAME_WIDTH - ball.width);
                        ball.y := clamp(ball.y, 0, GAME_HEIGHT - ball.height);

                        IF ball.x = 1 OR ball.x = GAME_WIDTH - ball.width THEN
                            IF ball.x = 1 THEN
                                p2Score := p2Score + 1;
                            ELSIF ball.x = GAME_WIDTH - ball.width THEN
                                p1Score := p1Score + 1;
                            END IF;

                            ball.y := GAME_HEIGHT / 2;
                            ball.x := GAME_WIDTH /2;
                        END IF;

                        printScore((GAME_WIDTH/2) - 30, 32, p1Score);
                        printScore((GAME_WIDTH/2) + 30, 32, p2Score);

                        drawNet;
                        drawWall;

                        drawRectangle(ball, '1', '1', '0');
                        drawRectangle(player1, '1', '0', '0');
                        drawRectangle(player2, '0', '0', '1');

                        updateScoreboard(p1Score, p2Score);

                        IF p1Score = 7 OR p2Score = 7 THEN
                            CurrentState <= WIN;
                        END IF;

                    WHEN WIN =>

                        IF p1Score = 7 THEN
                            winner := 1;
                        ELSIF p2Score = 7 THEN
                            winner := 2;
                        END IF;

                        drawWin(winner);

                        IF P1_READY = '1' OR P2_READY = '1' THEN
                            p1Score := 0;
                            p2Score := 0;
                            CurrentState <= IDLE;
                        END IF;

                END CASE;

            END IF;

            IF x > 0 AND x <= X_SYNC_PULSE THEN
                HSYNC <= '0';
            ELSE
                HSYNC <= '1';
            END IF;

            IF y > 0 AND y <= Y_SYNC_PULSE THEN
                VSYNC <= '0';
            ELSE
                VSYNC <= '1';
            END IF;

            x <= x + 1;
            IF x = X_WHOLE_LINE THEN
                y <= y + 1;
                x <= 0;
            END IF;

            IF y = Y_WHOLE_FRAME THEN
                y <= 0;
            END IF;
        END IF;

    END PROCESS;

END Behavioral;