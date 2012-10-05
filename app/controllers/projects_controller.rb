class ProjectsController < ApplicationController
  before_filter :init_api_token
  before_filter :init_project_and_date_range, :only => :show

  def index
    @projects = Project.all
  end

  def show
    stories = @project.stories
    iterations = @project.iterations

    chart_presenter = ChartPresenter.new(iterations, stories, @start_date, @end_date)
    time_chart_presenter = TimeChartPresenter.new(iterations, stories, @start_date, @end_date)
    @active_iterations = chart_presenter.active_iterations

    @velocity_range_chart = chart_presenter.whole_project_velocity_chart()
    @velocity_range_chart.description = ""

    @charts = []
    @charts << time_chart_presenter.accepted_story_types_chart

    @charts << time_chart_presenter.story_types_time_chart

    @charts << time_chart_presenter.impediments_time_chart

  end

  private

  def init_api_token
    tracker_session = session[TrackerApi::API_TOKEN_KEY]
    TrackerResource.init_session(tracker_session.api_token, tracker_session.session_key)
  end

  def init_project_and_date_range
    @project  = Project.find(params[:id].to_i)

    @start_date = Date.parse(params[:start_date]) unless params[:start_date].blank?
    @end_date = Date.parse(params[:end_date]) unless params[:end_date].blank?

    @story_filter = []
    Story::ALL_STORY_TYPES.each do |type|
      if not params[type].blank?
        @story_filter << type
      end
    end

    @story_filter = ChartPresenter::DEFAULT_STORY_TYPES if @story_filter.empty?
    @story_filter.each do |type|
      params[type] = '1'
    end
  end
end
