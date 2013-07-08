@FormBuilder.module "FormApp.Edit", (Edit, App, Backbone, Marionette, $, _) ->

  class Edit.Layout extends App.Views.Layout
    template: "formbuilder/edit/edit_layout"

    regions:
      titleRegion     : "#title-region"
      formRegion      : "#form-region"
      paletteRegion   : "#palette-region"

    triggers:
      "click [data-form-button='submit']" : "form:save"
      "click [data-form-button='cancel']" : "form:cancel"

  class Edit.Title extends App.Views.ItemView
    template: "formbuilder/edit/_title"
    modelEvents:
      "updated" : "render"

  class Edit.Empty extends App.Views.ItemView
    template: "formbuilder/edit/_empty"
    className: "empty"

  class Edit.FormComponent extends App.Views.ItemView
    tagName: "li"
    className: "form-component"
    getTemplate: ->
      name = @model.templateName()
      "formbuilder/edit/_#{name}"

    events:
      'drop'  : 'drop'

    triggers:
      "click .form-delete" : "form:field:delete"

    drop: (event, index) ->
      $(@el).trigger 'update-sort', [@model, index]

  class Edit.Form extends App.Views.CompositeView
    id: 'form'
    template: "formbuilder/edit/_form"
    itemView: Edit.FormComponent
    emptyView: Edit.Empty
    itemViewContainer: "ul"

    events:
      'update-sort' : 'updateSort'

    updateSort: (event, model, position) ->
      @trigger "form:component:sort", model, position

    onShow: ->
      $(@itemViewContainer).sortable
        revert: true
        items: ".form-component:not(.empty)"
        update: (event, ui) ->
          # remove drag helper
          $('#form .ui-draggable').remove()
          # trigger sort
          ui.item.trigger 'drop', ui.item.index()
        receive: (event, ui) =>
          @trigger "form:component:add", @cid, @index
        beforeStop: (event, ui) =>
          @cid = ui.item.attr 'data-cid'
          @index = ui.item.index()

  class Edit.PaletteComponent extends App.Views.ItemView
    template: "formbuilder/edit/_palette_component"
    tagName: "li"

    onShow: ->
      $(@el).draggable
        connectToSortable: $('.ui-sortable')
        helper: "clone"
        opacity: 0.75
      .attr 'data-cid', @model.cid


  class Edit.Palette extends App.Views.CompositeView
    template: "formbuilder/edit/_palette"
    itemView: Edit.PaletteComponent
    itemViewContainer: "ul"

