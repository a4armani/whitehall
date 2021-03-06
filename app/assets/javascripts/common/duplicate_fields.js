(function () {
  "use strict"
  var root = this,
      $ = root.jQuery;
  if(typeof root.GOVUK === 'undefined') { root.GOVUK = {}; }

  var duplicateFields = {
    init: function(){
      duplicateFields.$sets = $('.js-duplicate-fields');

      duplicateFields.addButton();
      duplicateFields.removeButton();
      duplicateFields.hideDestroyedFields();
    },
    addButton: function(){
      duplicateFields.$sets.each(function(){
        var $set = $(this),
            $button = $('<a href="#" class="btn add_new js-add-button">Add another</a>');

        $set.append($button);
        $button.on('click', duplicateFields.addFields);
      });
    },
    addFields: function(e){
      e.preventDefault();
      var $button = $(e.target),
          $set = $button.closest('.js-duplicate-fields'),
          $fields = $set.find('.js-duplicate-fields-set').last(),
          $newFields = $fields.clone(true);

      $newFields.find('input[type=text], input[type=hidden], textarea').val('');
      $newFields.show();
      duplicateFields.incrementIndexes($newFields);
      $button.before($newFields);
    },
    removeButton: function(){
      duplicateFields.$sets.each(function(){
        var $set = $(this),
            $button = $('<a href="#" class="btn btn-danger js-remove-button">Remove</a>'),
            $fields = $set.find('.js-duplicate-fields-set');

        $fields.append($button);
        $fields.find('a.js-remove-button').on('click', duplicateFields.removeFields);
      });
    },
    removeFields: function(e){
      e.preventDefault();
      var $button = $(e.target),
          $set = $button.closest('.js-duplicate-fields-set')

      var $destroy_input = duplicateFields.destroyInputFor($set);

      $set.hide();
      $set.find('input').val('');
      $set.append($destroy_input);
    },
    destroyInputFor: function(set){
      var $text_input = set.find('input[type=text], textarea').first(),
          baseName = $text_input.attr('name'),
          baseId = $text_input.attr('id'),
          destroyId = baseId.replace(/_[a-zA-Z]+$/, '__destroy'),
          destroyName = baseName.replace(/\[[_a-zA-Z]+\]$/, '[_destroy]');

      return $('<input class="js-hidden-destroy" id="' + destroyId +'" name="' + destroyName + '" type="hidden" value="true" />');
    },
    hideDestroyedFields: function(){
      duplicateFields.$sets.each(function(){
        var $set = $(this),
            $destroyInput = $set.find('.js-hidden-destroy[value="true"], .js-hidden-destroy[value="1"]'),
            $destroyedFields = $destroyInput.closest('.js-duplicate-fields-set');

        $destroyedFields.hide();
      });
    },
    incrementIndexes: function(fields){
      fields.find('label,input,textarea,select').each(function(i, el){
        var $el = $(el),
            currentName = $el.attr('name'),
            currentId = $el.attr('id'),
            currentFor = $el.attr('for'),
            index = false,
            arrayMatcher = /(.*)\[([0-9]+)\](.*?)$/,
            underscoreMatcher = /(.*)_([0-9]+)_(.*?)$/,
            matched;

        if(currentName && arrayMatcher.exec(currentName)){
          matched = arrayMatcher.exec(currentName);
          index = parseInt(matched[2], 10);
          $el.attr('name', matched[1] + '['+ (index+1) +']' + matched[3]);
        }
        if(underscoreMatcher.exec(currentId)){
          matched = underscoreMatcher.exec(currentId);
          if(index === false){
            index = parseInt(matched[2], 10);
          }
          $el.attr('id', matched[1] + '_'+ (index+1) +'_' + matched[3]);
        }
        if(underscoreMatcher.exec(currentFor)){
          matched = underscoreMatcher.exec(currentFor);
          if(index === false){
            index = parseInt(matched[2], 10);
          }
          $el.attr('for', matched[1] + '_'+ (index+1) +'_' + matched[3]);
        }
      });
    }
  };
  root.GOVUK.duplicateFields = duplicateFields;
}).call(this);
