#Code Sheet Generators

_"A code sheet on every lock screen!"_

Various generators, written in Processing, for creating code sheets (Morse, semaphore, hex, etc.) of different resolutions and styles. The primary goals of this project were (in this order):

1. Learn Processing.
2. Build a code sheet "wallpaper" for my iPhone's lock screen.
3. Do something interesting visually with the [Puzzled Pint](http://puzzledpint.com/) logo.

It works well for my iPhone 5s. Your mileage may vary.

[example.jpg]

##Included Projects

- **code_sheet_wallpaper** : This is the main project for generating a code sheet wallpaper for the iPhone 5s. For other phones and resolutions, you may have to twiddle a few values.

- **code_sheet_phone_skin** : This is me experimenting with outputting a code sheet at a resolution compatible with [Nuvango](http://nuvango.com/) iPhone cases and skins/clings.

##Variables

This is not an exhaustive list, but some variables of interest include:

- **EXPORT_PDF** : Whether to write a PDF output file. Note that some of the image tinting doesn't translate very well to PDF. Your best bet here is to generate without a `BACKGROUND`.
- **BACKGROUND** : If false, don't draw a fancy background, just use solid black.
- **DOT_BACKGROUND** : If true, the background is a single large faded Puzzled Pint logo with dot stipples. Otherwise, it's a grid of Puzzled Pint logos.
- The call to the `size()` function within `setup()` defines the size of the canvas. If you modify this, there will be some other constants (X_OFFSET, Y_OFFSET) and magic numbers (in `drawBraille()` and `drawSemaphore()` for example) that you will have to twiddle with.
- **X_OFFSET** : Offset from the left of the canvas from which to start drawing the table. Useful for centering.
- **Y_OFFSET** : Offset from the top of the canvas from which to start drawing the table. Useful for avoiding the date and time, or any other notification area that might obscure the code sheet.

##TODO

- Does Processing let you define include files? I'd be good to offload some of the common functions and array constants into a single file.
- Make sizing a little more generic to better fit a variety of smartphone wallpapers. For example, make font size as well as the various hard-coded sizes within Morse and Semaphore scale along with the canvas size.
