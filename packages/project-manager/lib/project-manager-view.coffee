{$, $$, SelectListView, View} = require 'atom'
CSON = require 'season'
_ = require 'underscore-plus'

module.exports =
class ProjectManagerView extends SelectListView
  projectManager: null
  activate: ->
    new ProjectManagerView

  initialize: (serializeState) ->
    super
    @addClass('project-manager overlay from-top')

  serialize: ->

  getFilterKey: ->
    'title'

  destroy: ->
    @detach()

  getEmptyMessage: (itemCount, filteredItemCount) =>
    if not itemCount
      'No projects saved yet'
    else
      super

  toggle: (projectManager) ->
    @projectManager = projectManager
    if @hasParent()
      @cancel()
    else
      @attach()

  attach: ->
    projects = []
    currentProjects = CSON.readFileSync(@projectManager.file())
    for title, project of currentProjects
      if project.template?
        project = _.deepExtend(project, currentProjects[project.template])
      projects.push(project) if project.paths?

    sortBy = atom.config.get('project-manager.sortBy')
    if sortBy isnt 'default'
      projects = @sortBy(projects, sortBy)
    @setItems(projects)

    atom.workspaceView.append(@)
    @focusFilterEditor()

  viewForItem: ({title, paths, icon}) ->
    icon = icon or 'icon-chevron-right'
    $$ ->
      @li class: 'two-lines', 'data-project-title': title, =>
        @div class: "primary-line icon #{icon}", title
        if atom.config.get('project-manager.showPath')
          @div class: 'secondary-line no-icon', path for path in paths

  confirmed: (project) ->
    @cancel()
    @projectManager.openProject(project)

  sortBy: (arr, key) ->
    arr.sort (a, b) ->
      (a[key] || '\uffff').toUpperCase() > (b[key] || '\uffff').toUpperCase()