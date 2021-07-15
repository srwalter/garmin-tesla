using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.System as Sys;

class QuickTesla extends App.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state) {
    }

    function onStop(state) {
    }

    (:glance)
    function getGlanceView() {
        return [ new WidgetGlanceView() ];
    }

    function getInitialView() {
        if (!Sys.getDeviceSettings().phoneConnected) {
            return [ new OfflineView() ];
        }

        var data = new TeslaData();
        var view = new MainView(data);

        return [ view, new MainDelegate(data, view.method(:onReceive)) ];
    }
}
