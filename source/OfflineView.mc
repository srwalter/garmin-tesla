using Toybox.WatchUi as Ui;

class OfflineView extends Ui.View {

    //! Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.OfflineLayout(dc));
    }

}
