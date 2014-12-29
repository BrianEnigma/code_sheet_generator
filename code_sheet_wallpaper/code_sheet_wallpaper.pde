import processing.pdf.*;

static final boolean EXPORT_PDF = false;
static final boolean BACKGROUND = true;
static final boolean DOT_BACKGROUND = true;

static final String MORSE[] = 
{
    ".-" /*A*/, "-..." /*B*/, "-.-." /*C*/, "-.." /*D*/, "." /*E*/, "..-." /*F*/, "--." /*G*/, "...." /*H*/, ".." /*I*/, ".---" /*J*/, "-.-" /*K*/, ".-.." /*L*/, "--" /*M*/, "-." /*N*/, "---" /*O*/, ".--." /*P*/, "--.-" /*Q*/, ".-." /*R*/, "..." /*S*/, "-" /*T*/, "..-" /*U*/, "...-" /*V*/, ".--" /*W*/, "-..-" /*X*/, "-.--" /*Y*/, "--.." /*Z*/
};
static final int BRAILLE[] = 
{
    0x01 /*A*/, 0x05 /*B*/, 0x03 /*C*/, 0x0B /*D*/, 0x09 /*E*/, 0x07 /*F*/, 0x0F /*G*/, 0x0D /*H*/, 0x06 /*I*/, 0x0E /*J*/, 0x11 /*K*/, 0x15 /*L*/, 0x13 /*M*/, 0x1B /*N*/, 0x19 /*O*/, 0x17 /*P*/, 0x1F /*Q*/, 0x1D /*R*/, 0x16 /*S*/, 0x1E /*T*/, 0x31 /*U*/, 0x35 /*V*/, 0x2E /*W*/, 0x33 /*X*/, 0x3B /*Y*/, 0x39 /*Z*/
};

static final int SEMAPHORE[] =
{
    0x18 /*A*/, 0x28 /*B*/, 0x48 /*C*/, 0x88 /*D*/, 0x09 /*E*/, 0x0A /*F*/, 0x0C /*G*/, 0x30 /*H*/, 0x50 /*I*/, 0x82 /*J*/, 0x90 /*K*/, 0x11 /*L*/, 0x12 /*M*/, 0x14 /*N*/, 0x60 /*O*/, 0xA0 /*P*/, 0x21 /*Q*/, 0x22 /*R*/, 0x24 /*S*/, 0xC0 /*T*/, 0x41 /*U*/, 0x84 /*V*/, 0x03 /*W*/, 0x05 /*X*/, 0x42 /*Y*/, 0x06 /*Z*/
};

static final int X_OFFSET = 70;
static final int Y_OFFSET = 350;
static final int ROW_HEIGHT = 25;

String makeBinary(int i)
{
    String result = "";
    while (i != 0)
    {
        result = (((i & 0x01) == 0x01) ? "1" : "0") + result;
        i >>= 1;
    }
    while (result.length() < 5)
        result = "0" + result;
    return result;
}

String makeTernary(int i)
{
    String result = "";
    while (i != 0)
    {
        result = String.format("%d", i % 3) + result;
        i /= 3;
    }
    while (result.length() < 3)
        result = "0" + result;
    return result;
}

String makeMorse(int i)
{
    String result = "";
    String ascii = MORSE[i];
    int codePointDot[] = {0x25CF, 0};
    int codePointDash[] = {0x25AC, 0};
    String unicodeDot = new String(codePointDot, 0, 1);
    String unicodeDash = new String(codePointDash, 0, 1);
    for (int pos = 0; pos < ascii.length(); pos++)
    {
        if (ascii.charAt(pos) == '-')
        {
            result += unicodeDash + " ";
        } else if (ascii.charAt(pos) == '.')
        {
            result += unicodeDot + " ";
        } else 
        {
            result += ascii.charAt(pos);
        }
    }
    return result.trim();
}

void drawBraille(int dots, int xPos, int yPos)
{
    yPos -= 5 * 2;
    xPos += 5;
    stroke(0);
    for (int dot = 0; dot < 6; dot++)
    {
        boolean isSet = (dots & (0x01 << dot)) != 0;
        int x = xPos + (dot % 2) * 5;
        int y = yPos + (dot / 2) * 5;
        if (isSet)
        {
            strokeWeight(1);
            fill(255);
            ellipse(x, y, 5, 5);
        } else {
            strokeWeight(1);
            fill(192);
            ellipse(x, y, 3, 3);
        }
    }
    strokeWeight(1);
}

void drawSemaphore(int dots, int xPos, int yPos)
{
    yPos = yPos - 5 * 2 + 4;
    xPos += 15;
    fill(0, 0, 0, 128);
    noStroke();
    ellipse(xPos, yPos, 17, 17);
    noFill();
    stroke(92, 0, 0);
    ellipse(xPos, yPos, 17, 17);
    for (int bit = 0; bit < 8; bit++)
    {
        int termX = xPos;
        int termY = yPos;
        switch(bit)
        {
            case 0: termX += 6; termY -= 6; break;
            case 1: termX += 8;             break;
            case 2: termX += 6; termY += 6; break;
            case 3:             termY += 8; break;
            case 4: termX -= 6; termY += 6; break;
            case 5: termX -= 8;             break;
            case 6: termX -= 6; termY -= 6; break;
            case 7:             termY -= 8; break;
        }
        stroke(255, 0, 0);
        strokeWeight(2);
        if ((dots & (0x01 << bit)) != 0)
            line(xPos, yPos, termX, termY);
        strokeWeight(1);
    }
    noStroke();
}

void doText(String s, int x, int y, int r, int g, int b)
{
    fill(0, 0, 0, 64);
    for (int xOffset = -3; xOffset <= 3; xOffset++)
        for (int yOffset = -3; yOffset <= 3; yOffset++)
            text(s, x + xOffset, y + yOffset);
    fill(0, 0, 0, 0);
    for (int xOffset = -1; xOffset <= 1; xOffset++)
        for (int yOffset = -1; yOffset <= 1; yOffset++)
            text(s, x + xOffset, y + yOffset);
    fill(r, g, b);
    text(s, x, y);
}

static final int COLUMN_WIDTHS[] = {
//  dec hex bin tern oct morse braille semaphore
    50, 50, 75, 60,  50, 20,   100,    50
};

void backgroundDots()
{
    final int DIAMETER = 10;
    final int DISTANCE = 15;
    for (int y = 0; y < height; y += DISTANCE)
    {
        int offset = ((y / DISTANCE % 2) == 0) ? 0 : DISTANCE / 2;
        for (int x = 0; x < width; x += DISTANCE)
        {
            //fill(96);
            fill(128);
            ellipse(x + offset + 1, y + 1, DIAMETER, DIAMETER);
            fill(32);
            ellipse(x + offset, y, DIAMETER, DIAMETER);
        }
    }
}

void backgroundLogo()
{
    PImage photo = loadImage("logo.png");
    
    tint(64);
    image(photo, width / 2 - photo.width * 0.5 / 2, Y_OFFSET + 40, photo.width * 0.5, photo.height * 0.5);
}

void backgroundMultiLogos()
{
    final int OFFSET_X = -6;
    final int OFFSET_Y = 7;
    PImage logo1 = loadImage("logo2.png");
    PImage logo2 = loadImage("logo3.png");
    
    final int SKIP_X = 75;
    final int SKIP_Y = 115;
    for (int y = 0; y < height; y += SKIP_Y)
    {
        boolean alt = ((y / SKIP_Y) % 2) == 1;
        for (int x = 0; x < width; x += SKIP_X)
        {
            tint(96);
            image(alt ? logo2 : logo1, x + 1 + OFFSET_X, y + 1 + OFFSET_Y, logo1.width * 5 / 60, logo1.height * 5 / 60);
            tint(64);
            image(alt ? logo2 : logo1, x + OFFSET_X, y + OFFSET_Y, logo1.width * 5 / 60, logo1.height * 5 / 60);
            alt = !alt;
        }
    }
}

void setup()
{
    size(640, 1136);
    noLoop();
    if (EXPORT_PDF)
        beginRecord(PDF, "quickref.pdf"); 
}

void draw()
{
    int xPos = X_OFFSET;
    int column = 0;
    background(0, 0, 0);

    // Background
    if (BACKGROUND)
    {
        if (DOT_BACKGROUND)
        {
            backgroundDots();
            backgroundLogo();
        } else {
            backgroundMultiLogos();
        }
    }
    
    // Content
    PFont baseFont = createFont("DejaVu Sans Mono", 16, true);
    textFont(baseFont);
    fill(255);
    // Headings
    textAlign(RIGHT);
    xPos += COLUMN_WIDTHS[column++];
    text("Dec", xPos, Y_OFFSET - ROW_HEIGHT);
    xPos += COLUMN_WIDTHS[column++];
    text("Hex", xPos, Y_OFFSET - ROW_HEIGHT);
    xPos += COLUMN_WIDTHS[column++];
    text("Bin", xPos, Y_OFFSET - ROW_HEIGHT);
    xPos += COLUMN_WIDTHS[column++];
    text("Tern", xPos, Y_OFFSET - ROW_HEIGHT);
    xPos += COLUMN_WIDTHS[column++];
    text("Oct", xPos, Y_OFFSET - ROW_HEIGHT);
    textAlign(LEFT);
    xPos += COLUMN_WIDTHS[column++];
    text("Morse", xPos, Y_OFFSET - ROW_HEIGHT);
    textAlign(LEFT);
    xPos += COLUMN_WIDTHS[column++];
    text("Br", xPos, Y_OFFSET - ROW_HEIGHT);
    textAlign(LEFT);
    xPos += COLUMN_WIDTHS[column++];
    text("Sem", xPos, Y_OFFSET - ROW_HEIGHT);
    
    // Content
    for (int i = 0; i < 26; i++)
    {
        xPos = X_OFFSET;
        column = 0;
        // Letter
        textAlign(CENTER);
        fill(255);
        doText(String.valueOf((char) (i + 'A')), xPos, i * ROW_HEIGHT + Y_OFFSET, 255, 255, 255);
        
        // Dec
        textAlign(RIGHT);
        xPos += COLUMN_WIDTHS[column++];
        doText(String.valueOf((int) (i + 1)), xPos, i * ROW_HEIGHT + Y_OFFSET, 255, 255, 0);
        // Hex
        textAlign(RIGHT);
        fill(0, 255, 0);
        xPos += COLUMN_WIDTHS[column++];
        doText(String.format("%02X", i + 1), xPos, i * ROW_HEIGHT + Y_OFFSET, 0, 255, 0);
        // Bin
        textAlign(RIGHT);
        stroke(0);
        fill(0, 255, 0);
        xPos += COLUMN_WIDTHS[column++];
        doText(makeBinary(i + 1), xPos, i * ROW_HEIGHT + Y_OFFSET, 0, 255, 0);
        // Ternary
        textAlign(RIGHT);
        fill(128);
        xPos += COLUMN_WIDTHS[column++];
        doText(makeTernary(i + 1), xPos, i * ROW_HEIGHT + Y_OFFSET, 128, 128, 128);
        // Octal
        textAlign(RIGHT);
        fill(128);
        xPos += COLUMN_WIDTHS[column++];
        doText(String.format("%03o", i + 1), xPos, i * ROW_HEIGHT + Y_OFFSET, 128, 128, 128);
        // Morse Code
        textAlign(LEFT);
        fill(0, 255, 255);
        xPos += COLUMN_WIDTHS[column++];
        doText(makeMorse(i), xPos, i * ROW_HEIGHT + Y_OFFSET, 0, 255, 255);
        // Braille
        textAlign(LEFT);
        fill(255, 255, 255);
        xPos += COLUMN_WIDTHS[column++];
        drawBraille(BRAILLE[i], xPos, i * ROW_HEIGHT + Y_OFFSET);
        // Semaphore
        xPos += COLUMN_WIDTHS[column++];
        drawSemaphore(SEMAPHORE[i], xPos, i * ROW_HEIGHT + Y_OFFSET);
    }
    
    // Horizontal separators
    stroke(64);
    for (int i = 0; i < 26; i += 3)
    {
        int yPos = i * ROW_HEIGHT + Y_OFFSET - ROW_HEIGHT + 6;
        line(5, yPos, width - 5, yPos); 
    }
    if (EXPORT_PDF)
        endRecord();
    save("quickref.png");
}
