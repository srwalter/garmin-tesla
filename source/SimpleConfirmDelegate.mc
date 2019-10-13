using Toybox.WatchUi as Ui;

class SimpleConfirmDelegate extends Ui.ConfirmationDelegate {
    var _on_confirm;

    function initialize(on_confirm) {
        ConfirmationDelegate.initialize();
        _on_confirm = on_confirm;
    }

    function onResponse(response) {
        if (response == CONFIRM_YES) {
            _on_confirm.invoke();
        }
    }
}
