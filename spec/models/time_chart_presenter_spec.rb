require 'spec_helper'

describe TimeChartPresenter do

  def row_values(rows, num)
    rows[num].map { |c| c.v }
  end

  before :each do
    @sample_stories = [
        double(# -> Story is done and belongs to an old iteration
            :id => 1,
            :story_type => Story::FEATURE,
            :created_at => DateTime.parse("2011-12-01 10:01:00 Z"),
            :updated_at => DateTime.parse("2012-01-12 11:02:00 Z"),
            :current_state => "accepted",
            :accepted_at => DateTime.parse("2012-01-02 11:02:00 Z"),
            :estimate => 1,
            :accepted? => true,
            :activities => []),
        double(
            :id => 2,
            :story_type => Story::FEATURE,
            :created_at => DateTime.parse("2012-01-01 10:01:00 Z"), # -> planned
            :updated_at => DateTime.parse("2012-01-11 11:02:00 Z"),
            :current_state => "accepted",
            :accepted_at => DateTime.parse("2012-01-11 11:02:00 Z"),
            :estimate => 1,
            :accepted? => true,
            :activities => [# Time spent on this story --> 7 hrs / 7 hrs
                double(
                    :occurred_at => DateTime.parse("2012-01-01 10:01:00 Z"),
                    :event_type => "story_create",
                    :description => "James Kirk created the story",
                    :stories => [double(:current_state => "unscheduled")]
                ),
                double(
                    :occurred_at => DateTime.parse("2012-01-11 07:01:00 Z"),
                    :event_type => "story_update",
                    :description => "James Kirk started the story",
                    :stories => [double(
                                     :current_state => "started"
                                 )]
                ),
                double(         # story is updated, but story state is not changed
                    :occurred_at => DateTime.parse("2012-01-11 09:01:00 Z"),
                    :event_type => "story_update",
                    :description => "James Kirk edited &quot;Divert power from warp coils&quot;",
                    :stories => [double(
                                     :current_name => "new name"
                                 )]
                ),
                double(         # story is updated, but story state is not changed
                    :occurred_at => DateTime.parse("2012-01-11 10:01:00 Z"),
                    :event_type => "story_update",
                    :description => "James Kirk estimated &quot;Divert power from warp coils&quot; as 3 points",
                    :stories => [double(
                                     :current_name => "new name"
                                 )]
                ),
                double(
                    :occurred_at => DateTime.parse("2012-01-11 14:01:00 Z"),
                    :event_type => "story_update",
                    :description => "James Kirk finished the story",
                    :stories => [double(
                                     :current_state => "finished"
                                 )]
                ),
                double(
                    :occurred_at => DateTime.parse("2012-01-11 14:10:00 Z"),
                    :event_type => "story_update",
                    :description => "James Kirk delivered the story",
                    :stories => [double(
                                     :current_state => "delivered"
                                 )]
                ),
                double(
                    :occurred_at => DateTime.parse("2012-01-13 15:01:00 Z"),
                    :event_type => "story_update",
                    :description => "James Kirk accepted the story",
                    :stories => [double(
                                     :current_state => "accepted"
                                 )]
                )
            ]
        ),
        double(
            :id => 3,
            :story_type => Story::FEATURE,
            :created_at => DateTime.parse("2011-12-25 10:01:00 Z"), # -> planned
            :updated_at => DateTime.parse("2012-01-12 11:02:00 Z"),
            :current_state => "delivered",
            :estimate => 2,
            :accepted? => false,
            :activities => [# Time spent on this story --> 1d / 8 hrs
                double(
                    :occurred_at => DateTime.parse("2011-12-25 10:01:00 Z"),
                    :event_type => "story_create",
                    :description => "James Kirk created the story",
                    :stories => [double(:current_state => "unscheduled")]
                ),
                double(
                    :occurred_at => DateTime.parse("2012-01-11 11:02:00 Z"),
                    :event_type => "story_update",
                    :description => "James Kirk created the story",
                    :stories => [double(
                                     :current_state => "started"
                                 )]
                ),
                double(
                    :occurred_at => DateTime.parse("2012-01-12 11:02:00 Z"),
                    :event_type => "story_update",
                    :description => "James Kirk created the story",
                    :stories => [double(
                                     :current_state => "finished"
                                 )]
                ),
                double(
                    :occurred_at => DateTime.parse("2012-01-12 13:02:00 Z"),
                    :event_type => "story_update",
                    :description => "James Kirk created the story",
                    :stories => [double(
                                     :current_state => "delivered"
                                 )]
                )
            ]
        ),
        double(
            :id => 4,
            :story_type => Story::FEATURE,
            :created_at => DateTime.parse("2012-01-03 10:01:00 Z"),
            :updated_at => DateTime.parse("2012-01-13 10:01:00 Z"),
            :current_state => "rejected",
            :estimate => 2,
            :accepted? => false,
            :activities => [# Time spent on this story --> 4 hrs
                double(
                    :occurred_at => DateTime.parse("2012-01-03 10:01:00 Z"),
                    :event_type => "story_create",
                    :description => "James Kirk created the story",
                    :stories => [double(:current_state => "unscheduled")]
                ),
                double(
                    :occurred_at => DateTime.parse("2012-01-11 11:00:00 Z"),
                    :event_type => "story_update",
                    :description => "James Kirk created the story",
                    :stories => [double(
                                     :current_state => "started"
                                 )]
                ),
                double(
                    :occurred_at => DateTime.parse("2012-01-11 15:00:00 Z"),
                    :event_type => "story_update",
                    :description => "James Kirk created the story",
                    :stories => [double(
                                     :current_state => "finished"
                                 )]
                ),
                double(
                    :occurred_at => DateTime.parse("2012-01-11 15:02:00 Z"),
                    :event_type => "story_update",
                    :description => "James Kirk created the story",
                    :stories => [double(
                                     :current_state => "delivered"
                                 )]
                ),
                double(
                    :occurred_at => DateTime.parse("2012-01-11 13:02:00 Z"),
                    :event_type => "story_update",
                    :description => "James Kirk created the story",
                    :stories => [double(
                                     :current_state => "rejected"
                                 )]
                )
            ]
        ),
        double(
            :id => 5,
            :story_type => Story::CHORE,
            :created_at => DateTime.parse("2012-01-04 10:01:00 Z"), # -> planned
            :updated_at => DateTime.parse("2012-01-16 10:01:00 Z"),
            :current_state => "finished",
            :accepted? => false,
            :activities => [# Time spent on this story -->  3d 4h + 4h  = 32
                double(
                    :occurred_at => DateTime.parse("2012-01-04 10:01:00 Z"),
                    :event_type => "story_create",
                    :description => "James Kirk created the story",
                    :stories => [double(:current_state => "unscheduled")]
                ),
                double(
                    :occurred_at => DateTime.parse("2012-01-12 11:00:00 Z"),
                    :event_type => "story_update",
                    :description => "James Kirk created the story",
                    :stories => [double(
                                     :current_state => "started"
                                 )]
                ),
                double(
                    :occurred_at => DateTime.parse("2012-01-12 15:00:00 Z"),
                    :event_type => "story_update",
                    :description => "James Kirk created the story",
                    :stories => [double(
                                     :current_state => "unstarted"
                                 )]
                ),
                double(
                    :occurred_at => DateTime.parse("2012-01-13 11:00:00 Z"),
                    :event_type => "story_update",
                    :description => "James Kirk created the story",
                    :stories => [double(
                                     :current_state => "started"
                                 )]
                ),
                double(
                    :occurred_at => DateTime.parse("2012-01-16 15:00:00 Z"),
                    :event_type => "story_update",
                    :description => "James Kirk created the story",
                    :stories => [double(
                                     :current_state => "finished"
                                 )]
                )
            ]

        ),
        double(
            :id => 6,
            :story_type => Story::BUG,
            :created_at => DateTime.parse("2012-01-05 10:01:00 Z"), # -> planned
            :updated_at => DateTime.parse("2012-01-16 10:01:00 Z"),
            :current_state => "started", #
            :accepted? => false,
            :activities => [# Time spent on this story -->  1d / 8h
                double(
                    :occurred_at => DateTime.parse("2012-01-05 10:00:00 Z"),
                    :event_type => "story_create",
                    :description => "James Kirk created the story",
                    :stories => [double(:current_state => "unscheduled")]
                ),
                double(
                    :occurred_at => DateTime.parse("2012-01-16 10:00:00 Z"),
                    :event_type => "story_update",
                    :description => "James Kirk created the story",
                    :stories => [double(
                                     :current_state => "started"
                                 )]
                )
            ]
        ),
        double(
            :id => 7,
            :story_type => Story::FEATURE,
            :created_at => DateTime.parse("2012-01-11 10:01:00 Z"), # -> impediment
            :updated_at => DateTime.parse("2012-01-16 11:02:00 Z"),
            :current_state => "accepted",
            :accepted_at => DateTime.parse("2012-01-16 11:02:00 Z"),
            :estimate => 1,
            :accepted? => true,
            :activities => [# Time spent on this story --> 4 hrs / 4 hrs
                double(
                    :occurred_at => DateTime.parse("2012-01-11 10:01:00 Z"),
                    :event_type => "story_create",
                    :description => "James Kirk created the story",
                    :stories => [double(:current_state => "unscheduled")]
                ),
                double(
                    :occurred_at => DateTime.parse("2012-01-12 07:01:00 Z"),
                    :event_type => "story_update",
                    :description => "James Kirk started the story",
                    :stories => [double(
                                     :current_state => "started"
                                 )]
                ),
                double(         # story is updated, but story state is not changed
                    :occurred_at => DateTime.parse("2012-01-12 09:01:00 Z"),
                    :event_type => "story_update",
                    :description => "James Kirk edited &quot;Divert power from warp coils&quot;",
                    :stories => [double(
                                     :current_name => "new name"
                                 )]
                ),
                double(         # story is updated, but story state is not changed
                    :occurred_at => DateTime.parse("2012-01-12 10:01:00 Z"),
                    :event_type => "story_update",
                    :description => "James Kirk estimated &quot;Divert power from warp coils&quot; as 3 points",
                    :stories => [double(
                                     :current_name => "new name"
                                 )]
                ),
                double(
                    :occurred_at => DateTime.parse("2012-01-12 11:01:00 Z"),
                    :event_type => "story_update",
                    :description => "James Kirk finished the story",
                    :stories => [double(
                                     :current_state => "finished"
                                 )]
                ),
                double(
                    :occurred_at => DateTime.parse("2012-01-12 14:10:00 Z"),
                    :event_type => "story_update",
                    :description => "James Kirk delivered the story",
                    :stories => [double(
                                     :current_state => "delivered"
                                 )]
                ),
                double(
                    :occurred_at => DateTime.parse("2012-01-13 15:01:00 Z"),
                    :event_type => "story_update",
                    :description => "James Kirk accepted the story",
                    :stories => [double(
                                     :current_state => "accepted"
                                 )]
                )
            ]
        ),
        double(
            :id => 8,
            :story_type => Story::CHORE,
            :created_at => DateTime.parse("2012-01-16 10:00:00 Z"), # -> impediment
            :updated_at => DateTime.parse("2012-01-16 16:00:00 Z"),
            :current_state => "started",
            :accepted? => false,
            :activities => [# Time spent on this story -->  18h --> 8h
                double(
                    :occurred_at => DateTime.parse("2012-01-16 10:00:00 Z"),
                    :event_type => "story_create",
                    :description => "James Kirk created the story",
                    :stories => [double(:current_state => "unscheduled")]
                ),
                double(
                    :occurred_at => DateTime.parse("2012-01-16 16:00:00 Z"),
                    :event_type => "story_update",
                    :description => "James Kirk created the story",
                    :stories => [double(
                                     :current_state => "started"
                                 )]
                )
            ]
        ),
        double(
            :id => 9,
            :story_type => Story::BUG,
            :created_at => DateTime.parse("2012-01-14 10:01:00 Z"), # -> impediment
            :updated_at => DateTime.parse("2012-01-18 10:01:00 Z"),
            :current_state => "started", #
            :accepted? => false,
            :activities => [# Time spent on this story -->  2d 4h  = 20h
                double(
                    :occurred_at => DateTime.parse("2012-01-14 10:01:00 Z"),
                    :event_type => "story_create",
                    :description => "James Kirk created the story",
                    :stories => [double(:current_state => "unscheduled")]
                ),
                double(
                    :occurred_at => DateTime.parse("2012-01-15 11:00:00 Z"),
                    :event_type => "story_update",
                    :description => "James Kirk created the story",
                    :stories => [double(
                                     :current_state => "started"
                                 )]
                ),
                double(
                    :occurred_at => DateTime.parse("2012-01-17 15:00:00 Z"),
                    :event_type => "story_update",
                    :description => "James Kirk created the story",
                    :stories => [double(
                                     :current_state => "finished"
                                 )]
                )
            ]
        ),

        # ICEBOX
        double(
            :id => 10,
            :story_type => Story::FEATURE,
            :created_at => DateTime.parse("2012-01-01 00:01:00 Z"), # iteration 0
            :updated_at => DateTime.parse("2012-01-01 00:01:00 Z"), # iteration 0
            :current_state => "unscheduled",
            :accepted? => false,
            :activities => []),

        # BACKLOG
        double(
            :id => 11,
            :story_type => Story::BUG,
            :created_at => DateTime.parse("2012-01-01 00:01:00 Z"), # iteration 3
            :updated_at => DateTime.parse("2012-01-15 09:01:00 Z"), # iteration 3
            :current_state => "unstarted",
            :accepted? => false,
            :activities => [])
    ]


    stories = double("project stories")
    stories.stub(:all).and_return(@sample_stories)

    @iterations = [
        double(
            :number => 1,
            :start_date => Date.parse("2012-01-01"),
            :finish_date => Date.parse("2012-01-10"),
            :stories => []),
        double(
            :number => 2,
            :start_date => Date.parse("2012-01-10"),
            :finish_date => Date.parse("2012-01-20"),
            :stories => []),
        double(
            :number => 3,
            :start_date => Date.parse("2012-01-20"),
            :finish_date => Date.parse("2012-01-30"),
            :stories => []),
        double(
            :number => 4,
            :start_date => Date.parse("2012-01-30"),
            :finish_date => Date.parse("2012-02-10"),
            :stories => [])
    ]

    @iterations[0].stories << @sample_stories[0]
    @iterations[1].stories << @sample_stories[1]
    @iterations[1].stories << @sample_stories[2]
    @iterations[1].stories << @sample_stories[3]
    @iterations[1].stories << @sample_stories[4]
    @iterations[1].stories << @sample_stories[5]
    @iterations[1].stories << @sample_stories[6]
    @iterations[1].stories << @sample_stories[7]
    @iterations[1].stories << @sample_stories[8]
    @iterations[2].stories << @sample_stories[9]
    @iterations[2].stories << @sample_stories[10]

    Time.stub!(:now).and_return(Time.utc(2012, 01, 17, 10, 00, 00))
  end

  describe "current iteration" do

    it "should return current iteration if the date range is not specified" do

      chart_presenter = TimeChartPresenter.new(@iterations, @sample_stories)
      current_iteration = chart_presenter.current_iteration

      current_iteration.number.should == 2
    end

    it "should return current iteration even if the date range is specified" do

      chart_presenter = TimeChartPresenter.new(@iterations,
                                               @sample_stories,
                                               DateTime.parse("2012-01-07 00:01:00 Z"),
                                               DateTime.parse("2012-02-07 00:01:00 Z"))
      current_iteration = chart_presenter.current_iteration

      current_iteration.number.should == 2
    end

  end

  describe "active iterations" do
    it "should return zero iterations for active date range before the first iteration" do
      chart_presenter = TimeChartPresenter.new(@iterations,
                                               @sample_stories,
                                               DateTime.parse("2010-01-17 00:01:00 Z"),
                                               DateTime.parse("2010-01-23 00:02:00 Z"))
      active_iterations = chart_presenter.active_iterations

      active_iterations.length.should == 0
    end

    it "should return zero iterations for active date range after the last iteration" do
      # Case #4
      chart_presenter = TimeChartPresenter.new(@iterations,
                                               @sample_stories,
                                               DateTime.parse("2012-02-07 00:01:00 Z"),
                                               DateTime.parse("2012-02-23 00:02:00 Z"))
      active_iterations = chart_presenter.active_iterations

      active_iterations.length.should == 0
    end

    it "should return only current iteration if the date range is not specified" do
      expected_first_iteration_nr = @iterations[1].number
      expected_last_iteration_nr = @iterations[1].number


      chart_presenter = TimeChartPresenter.new(@iterations, @sample_stories)
      active_iterations = chart_presenter.active_iterations

      active_iterations.length.should == 1

      active_iterations.first.number.should == expected_first_iteration_nr
      active_iterations.last.number.should == expected_last_iteration_nr
    end

    it "should return iterations starting after start date and ending before end date" do
      expected_first_iteration_nr = @iterations[1].number
      expected_last_iteration_nr = @iterations[2].number


      chart_presenter = TimeChartPresenter.new(@iterations,
                                               @sample_stories,
                                               DateTime.parse("2012-01-07 00:01:00 Z"),
                                               DateTime.parse("2012-02-07 00:01:00 Z"))
      active_iterations = chart_presenter.active_iterations

      active_iterations.length.should == 2

      active_iterations.first.number.should == expected_first_iteration_nr
      active_iterations.last.number.should == expected_last_iteration_nr
    end

  end

  describe "active stories" do
    it "should return all stories updated during the given date range" do
      chart_presenter = TimeChartPresenter.new(@iterations,
                                               @sample_stories,
                                               DateTime.parse("2012-01-13 00:01:00 Z"),
                                               DateTime.parse("2012-01-20 00:01:00 Z"))
      active_stories = chart_presenter.active_stories

      active_stories.length.should == 7
    end

    it "should exclude the stories which are accepted before the given date range" do
      chart_presenter = TimeChartPresenter.new(@iterations,
                                               @sample_stories,
                                               DateTime.parse("2012-01-10 00:01:00 Z"),
                                               DateTime.parse("2012-01-13 00:01:00 Z"))
      active_stories = chart_presenter.active_stories

      active_stories.length.should == 2
    end

    #it "should return all stories in the current sprint if the date is not specified" do
    #  chart_presenter = TimeChartPresenter.new(@iterations,
    #                                           @sample_stories )
    #  active_stories = chart_presenter.active_stories
    #
    #  active_stories.length.should == 8
    #end

  end

  context "feature/bug/chore charts" do
    let(:chart) { @chart_presenter.send(chart_method) }

    before do
      @chart_presenter = TimeChartPresenter.new(@iterations, @sample_stories, Date.parse("2012-01-10"), Date.parse("2012-01-20"))
    end

    describe "#story_types_time_chart" do
      let(:chart_method) { "story_types_time_chart" }

      it_should_behave_like "a chart generation method"

      it "produces a chart" do
        rows = chart.data_table.rows

        row_values(rows, 0).should == ["Features", 23] # 7 + 8 + 4 + 4
        row_values(rows, 1).should == ["Bugs", 28]     #8 + 20
        row_values(rows, 2).should == ["Chores", 40]   #32 + 8

      end
    end

    describe "#impediments_time_chart" do
      let(:chart_method) { "impediments_time_chart" }

      it_should_behave_like "a chart generation method"

      it "produces a chart" do
        rows = chart.data_table.rows

        row_values(rows, 0).should == ["Impediments", 32] #24h + 8h + 5h
        row_values(rows, 1).should == ["Stories", 59]

      end
    end

  end


end