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
        .appendTo('#translations');
    $('<h3></h3>').text('Translation ' + translations).appendTo(div);
    var row = $('<tr></tr>').appendTo(div);

    $('<td></td>')
        .text('Key')
        .addClass('table-header')
        .appendTo(row);
    if (translations == "1") {
        key = key + "."
    }
    $('<input />')
        .addClass('key_input new_translation')
        .attr({'name': 'translations[' + translations + '[key]]', 'type': 'text', 'value': key, 'size': '60'})
        .appendTo($('<td></td>').appendTo(row));

    locales = localStorage.getItem('locales').split(',');
    var counter = locales.length;

    for(var i = 0; i < counter; i++)
    {
        renderAllLocalfields(locales[i], translations);
    }

    var add_row = $('<tr></tr>').appendTo(div);
    $('<td></td>')
        .text('Add translation')
        .addClass('table-header')
        .appendTo(add_row);

    var table_new = $('<td></td>')
        .appendTo(add_row);

    $('<a></a>')
        .text('+')
        .attr({'href': '#', 'onclick': 'addTranslation();'})
        .appendTo(table_new);
}

function renderAllLocalfields(locale, translations) {
    var tr = $('<tr></tr>');
    $('<td></td>').text(locale).addClass('table-header').appendTo(tr);
    var td_input = $('<td></td>').appendTo(tr);
    var textarea = $('<textarea></textarea>')
        .addClass('key_input')
        .attr({'name': 'translations[' + translations + '[locales[' + locale + ']]]', 'cols': '60', 'rows': '3'})
        .appendTo(td_input);
    var count = $('#translations').children().length;
    var appendElement = $('.translation-' + count)[0];

    tr.appendTo(appendElement);
}
