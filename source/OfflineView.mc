using Toybox.WatchUi as Ui;

class OfflineView extends Ui.View {

    function initialize() {
        View.initialize();
    }

    function onLayout(dc) {
        setLayout(Rez.Layouts.OfflineLayout(dc));
    }

}
