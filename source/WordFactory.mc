using Toybox.Graphics;
using Toybox.WatchUi;

class WordFactory extends WatchUi.PickerFactory {
    var mWords;
    var mFont;

    function initialize(words) {
        PickerFactory.initialize();

        mWords = words;
        mFont = Graphics.FONT_SMALL;
    }

    function getSize() {
        return mWords.size();
    }

    function getValue(index) {
        return mWords[index];
    }

    function getDrawable(index, selected) {
        return new WatchUi.Text({:text=>mWords[index], :color=>Graphics.COLOR_WHITE, :font=>mFont, :locX=>WatchUi.LAYOUT_HALIGN_CENTER, :locY=>WatchUi.LAYOUT_VALIGN_CENTER});
    }
}
