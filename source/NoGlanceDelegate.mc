using Toybox.WatchUi as Ui;

class NoGlanceDelegate extends Ui.BehaviorDelegate {

    var tesla_data;

    function initialize(data) {
        BehaviorDelegate.initialize();
        tesla_data = data;
    }

    function onSelect() {
        var view = new MainView(tesla_data);
        Ui.pushView(view, new MainDelegate(tesla_data, view.method(:onReceive)), Ui.SLIDE_UP);
        return true;
    }

}