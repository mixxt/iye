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

function rememberFileSelection(form) {
    var filename = form.elements.namedItem("key[path_template]").value;
    localStorage.setItem("filename", filename);
}

function restoreFileSelection(form) {
    if (localStorage.getItem("filename")) {
        form.elements.namedItem("key[path_template]").value = localStorage.getItem("filename");
    }
}
