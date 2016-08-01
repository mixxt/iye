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
    var div = $('<div></div>')
        .addClass(('translation-' + translations) + ' form-group')
        .appendTo('#translations');

    var label_div = $('<div></div>').addClass('col-sm-12').appendTo(div);
    var label = $('<label></label>').addClass('col-sm-2 control-label').appendTo(label_div);
    var h1 = $('<h1></h1>').appendTo(label);
    $('<small></small>').text('Translation ' + translations).appendTo(h1);
    var row = $('<div></div>').addClass('form-group').appendTo(div);

    $('<label></label>')
        .text('Key')
        .addClass('col-sm-2 control-label')
        .appendTo(row);

    if (key.length > 0) {
        key = key + ".";
    }

    $('<input />')
        .addClass('key_input new_translation col-sm-10 form-control')
        .attr({'name': 'translations[' + translations + '[key]]', 'type': 'text', 'value': key, 'size': '60'})
        .appendTo($('<div></div>').addClass('col-sm-10').appendTo(row));

    locales = localStorage.getItem('locales').split(',');
    var counter = locales.length;

    for(var i = 0; i < counter; i++)
    {
        renderAllLocalfields(locales[i], translations, div);
    }

    var add_row = $('<div></div>').addClass('form-group').appendTo(div);
    $('<label></label>')
        .text('Add translation')
        .addClass('col-sm-2 control-label')
        .appendTo(add_row);

    var table_new = $('<div></div>')
        .addClass('col-sm-10')
        .appendTo(add_row);

    $('<a></a>')
        .text('+')
        .addClass('btn btn-primary')
        .attr({'href': '#', 'onclick': 'addTranslation();'})
        .appendTo(table_new);
}

function renderAllLocalfields(locale, translations, div) {
    var tr = $('<div></div>')
        .addClass('form-group')
        .appendTo(div);
    $('<label></label>')
        .text(locale)
        .addClass('col-sm-2 control-label')
        .appendTo(tr);
    var td_input = $('<div></div>')
        .addClass('col-sm-10')
        .appendTo(tr);
    var textarea = $('<textarea></textarea>')
        .addClass('key_input')
        .attr({'name': 'translations[' + translations + '[locales[' + locale + ']]]', 'cols': '60', 'rows': '3'})
        .appendTo(td_input);
    var count = $('#translations').children().length;
    var appendElement = $('.translation-' + count)[0];

    tr.appendTo(appendElement);
}
