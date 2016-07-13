/**
 * Disables all submits in a form action.
 */

//= require jquery2

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

function addTranslation() {
    var key = $('.global_key')[0].value;
    var translations = $('#translations').children().length;
    translations++;
    var div = $('<table></table>')
        .addClass(('translation-' + translations))
        .appendTo('tr#translations');
    var headline = $('<h3></h3>').text('Translation ' + translations).appendTo(div);
    var row = $('<tr></tr>').appendTo(div);

    var key_label = $('<td></td>')
        .text('Key')
        .appendTo(row);
    var key_input = $('<input />')
        .addClass('new_translation')
        .attr({'name': 'keys[id]', 'type': 'text', 'value': key, 'size': '60'})
        .appendTo($('<td></td>').appendTo(row));

    locales = localStorage.getItem('locales').split(',');
    var counter = locales.length;

    for(var i = 0; i < counter; i++)
    {
        renderAllLocalfields(locales[i]);
    }
}

function renderAllLocalfields(locale) {
    var tr = $('<tr></tr>');
    var td_label = $('<td></td>').text(locale).appendTo(tr);
    var td_input = $('<td></td>').appendTo(tr);
    var textarea = $('<textarea></textarea>')
        .attr({'name': 'key[translations][' + locale + ']', 'cols': '60', 'rows': '3'})
        .appendTo(td_input);
    var count = $('#translations').children().length;
    var appendElement = $('.translation-' + count)[0];

    tr.appendTo(appendElement);
}
