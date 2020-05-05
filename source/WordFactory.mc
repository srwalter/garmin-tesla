using Toybox.Graphics;
using Toybox.WatchUi;

class WordFactory extends WatchUi.PickerFactory {
    var mWords;
    var mFont;

    function initialize(words) {
        System.println("WordFactory initialize");
        PickerFactory.initialize();

        mWords = words;
        mFont = Graphics.FONT_SMALL;
        System.println("WordFactory end initialize");
    }

    function getSize() {
        System.println("WordFactory getSize");
        return mWords.size();
    }

    function getValue(index) {
        System.println("WordFactory getValue");
        return mWords[index];
    }

    function getDrawable(index, selected) {
        System.println("WordFactory getDrawable");
        return new WatchUi.Text({:text=>mWords[index], :color=>Graphics.COLOR_WHITE, :font=>mFont, :locX=>WatchUi.LAYOUT_HALIGN_CENTER, :locY=>WatchUi.LAYOUT_VALIGN_CENTER});
    }
}
