using Toybox.WatchUi as Ui;

class NoGlanceView extends Ui.View {

    function initialize() {
        View.initialize();
    }

    function onLayout(dc) {
        if (System.getDeviceSettings().isTouchScreen)
        {
            setLayout(Rez.Layouts.NoGlanceTouchLayout(dc));
        }
        else
        {
            setLayout(Rez.Layouts.NoGlancePressLayout(dc));
        }
    }
}
