using Toybox.Graphics;
using Toybox.WatchUi;

class WordFactory extends WatchUi.PickerFactory {
    var mWords;
    var mFont;

    function initialize(words) {
        logMessage("WordFactory initialize");
        PickerFactory.initialize();

        mWords = words;
        mFont = Graphics.FONT_SMALL;
        logMessage("WordFactory end initialize");
    }

    function getSize() {
        logMessage("WordFactory getSize");
        return mWords.size();
    }

    function getValue(index) {
        logMessage("WordFactory getValue");
        return mWords[index];
    }

    function getDrawable(index, selected) {
        logMessage("WordFactory getDrawable");
        return new WatchUi.Text({:text=>mWords[index], :color=>Graphics.COLOR_WHITE, :font=>mFont, :locX=>WatchUi.LAYOUT_HALIGN_CENTER, :locY=>WatchUi.LAYOUT_VALIGN_CENTER});
    }

    (:debug)
    function logMessage(message) {
        System.println(message);
    }

    (:release)
    function logMessage(message) {
        
    }
}
