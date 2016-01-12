/**
 * Disables all submits in a form action.
 */

function disableSubmit(form) {
    var inputs = form.getElementsByTagName('input');
    for (var i = 0; i < inputs.length; i++) {
        if (inputs[i].type === 'submit') {
            inputs[i].disabled = true;
        }
    }
}
