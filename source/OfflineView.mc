using Toybox.WatchUi as Ui;

class OfflineView extends Ui.View {

    function initialize() {
        View.initialize();
    }

    //! Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.OfflineLayout(dc));
    }

}
