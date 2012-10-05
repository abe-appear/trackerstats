require 'time_diff'

class TimeChartWrapper
  attr_accessor :description
  attr_reader :chart

  def initialize(chart, description)
    self.description = description
    @chart = chart
  end

  def method_missing(m, *args, &block)
    @chart.send m, *args, &block
  end
end

class TimeChartPresenter
  DEF_CHART_WIDTH = 1000
  DEF_CHART_HEIGHT = 500

  DEFAULT_STORY_TYPES = [
      Story::FEATURE,
      Story::BUG
  ]

  STORY_TYPE_COLORS = {
      Story::FEATURE => {default: '#3366CC', additional: '#80b3ff'},
      #FEATURE => {default: '#000000', additional: '#80b3ff'},
      Story::BUG     => {default: '#DC3912', additional: '#ff865f'},
      Story::CHORE   => {default: '#FF9900', additional: '#ffe64d'},
  }

  VELOCITY_COLOR = '#56A5EC'

  MIN_SCATTER_CHART_GRID_LINES = 2
  MAX_SCATTER_CHART_GRID_LINES = 50

  attr_accessor :stories, :start_date, :end_date

  def initialize(iterations, stories, start_date = nil, end_date = nil)
    @iterations = iterations
    @stories = stories

    @start_date = start_date ? start_date.to_date : current_iteration.present? ? current_iteration.start_date: Date.today
    @end_date = end_date ? end_date.to_date : current_iteration.present? ? current_iteration.finish_date: Date.today
  end

  def current_iteration
    valid_iterations = @iterations.select do |it|
      (it.finish_date > Time.now.to_date) && (it.start_date <= Time.now.to_date)
    end
    @current_iteration = valid_iterations.first
  end

  def active_iterations
    @active_iterations = @iterations.select do |it|
      (it.start_date >= @start_date) && (it.finish_date <= @end_date)
    end
  end

  def active_stories
    @active_stories = []
    @active_stories = @stories.select do |story|
      ( story.updated_at > @start_date && story.updated_at < @end_date && (story.accepted? ? (story.accepted_at > @start_date) : true))
    end
  end

  def story_types_time_chart(title = "Story Types Time Chart")
    colors = []
    data_table = GoogleVisualr::DataTable.new
    data_table.new_column('string', 'Story Type')
    data_table.new_column('number', 'Number')

    Story::ALL_STORY_TYPES.each do |type|
      colors << STORY_TYPE_COLORS[type][:default]
      data_table.add_row([type.pluralize.capitalize, time_spent_on_stories_with_types([type])])
    end

    opts = {
        :width => DEF_CHART_WIDTH,
        :height => DEF_CHART_HEIGHT,
        :title => title,
        :colors => colors}

    ChartWrapper.new(
        GoogleVisualr::Interactive::PieChart.new(data_table, opts),
        I18n.t(:story_types_time_chart_desc)
    )
  end

  def time_spent_on_story(story)
    activities = story.activities
    #puts "Printing the activities of story:"
    progress_time = 0
    last_started_time = 0
    activities.each do |activity|
      #puts "Activity description = #{activity.description}"
      #puts "Activity event type  = #{activity.event_type}"
      next unless activity.event_type == "story_update"
      next if activity.description.include? "edited"
      next if activity.description.include? "estimated"
      current_state = activity.stories.first.current_state
      #puts "current state = #{current_state}"
      #puts "activity occured = #{activity.occurred_at}"
      next if current_state == "unknown"
      unless last_started_time == 0
        time_difference  = Time.diff( activity.occurred_at , last_started_time)
        #puts "time difference = #{time_difference}"
        progress_time += (time_difference[:week] * 7 * 24) + (time_difference[:day] * 8) + time_difference[:hour]
        last_started_time = 0
        #puts "progress time"
        puts progress_time
      end
      if (current_state == "started")
        last_started_time = activity.occurred_at
      end
    end
    if (last_started_time != 0)
      # story is started, but not finished. The time in progress is from started time until now
      time_difference  = Time.diff( Time.now , last_started_time)
      #puts "time spent on story = #{time_difference}"
      progress_time += (time_difference[:week] * 7 * 24) + (time_difference[:day] * 8) + time_difference[:hour]
    end
    return progress_time
  end

  def time_spent_on_stories_with_types(types)
    #puts types
    result = 0;
    active_stories_with_types(types).each do |story|
      result += time_spent_on_story(story)
    end
    #puts result;
    return result;
  end

  def active_stories_with_types(types)
    active_stories.select do |story|
      (types.present? ? types.include?(story.story_type) : true)
    end
  end

end