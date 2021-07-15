using Toybox.WatchUi as Ui;

class SimpleView extends Ui.View {

    function initialize() {
        View.initialize();
    }

    function onLayout(dc) {
        setLayout(Rez.Layouts.MainLayout(dc));
    }

    function onShow() {
    }

    function onUpdate(dc) {
        View.onUpdate(dc);

        var wake_line_1_drawable = View.findDrawableById("wake_line_1");
        var wake_line_2_drawable = View.findDrawableById("wake_line_2");
        if (System.getDeviceSettings().isTouchScreen)
        {
                wake_line_1_drawable.setText(Ui.loadResource(Rez.Strings.wake_touch));
        }
        else
        {
                wake_line_1_drawable.setText(Ui.loadResource(Rez.Strings.wake_press_start));
        }
        wake_line_2_drawable.setText(Ui.loadResource(Rez.Strings.wake_vehicle));
        wake_line_1_drawable.draw(dc);
        wake_line_2_drawable.draw(dc);
    }

    function onHide() {
    }

}
