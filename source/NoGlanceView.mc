using Toybox.WatchUi as Ui;

class NoGlanceView extends Ui.View {

    function initialize() {
        View.initialize();
    }

    function onLayout(dc) {
        setLayout(Rez.Layouts.NoGlanceLayout(dc));
    }
}
