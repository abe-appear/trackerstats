require 'spec_helper'

describe TimeChartPresenter do

  def row_values(rows, num)
    rows[num].map { |c| c.v }
  end

  before :each do
    @sample_stories = [
        double(# -> Story is done and belongs to an old iteration
            :story_type => Story::FEATURE,
            :created_at => DateTime.parse("2011-12-01 10:01:00 Z"),
            :updated_at => DateTime.parse("2012-01-12 11:02:00 Z"),
            :current_state => "accepted",
            :accepted_at => DateTime.parse("2012-01-02 11:02:00 Z"),
            :estimate => 1,
            :accepted? => true,
            :activities => []),
        double(
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
            :story_type => Story::CHORE,
            :created_at => DateTime.parse("2012-01-04 10:01:00 Z"), # -> planned
            :updated_at => DateTime.parse("2012-01-16 10:01:00 Z"),
            :current_state => "finished",
            :accepted? => false,
            :activities => [# Time spent on this story -->  3d 4h + 4h
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
            :story_type => Story::FEATURE,
            :created_at => DateTime.parse("2012-01-11 10:01:00 Z"), # -> impediment
            :updated_at => DateTime.parse("2012-01-16 11:02:00 Z"),
            :current_state => "accepted",
            :accepted_at => DateTime.parse("2012-01-16 11:02:00 Z"),
            :estimate => 1,
            :accepted? => true,
            :activities => []),
        double(
            :story_type => Story::CHORE,
            :created_at => DateTime.parse("2012-01-17 10:01:00 Z"), # -> impediment
            :updated_at => DateTime.parse("2012-01-17 16:02:00 Z"),
            :current_state => "accepted",
            :accepted_at => DateTime.parse("2012-01-17 16:02:00 Z"),
            :accepted? => false,
            :activities => []),
        double(
            :story_type => Story::BUG,
            :created_at => DateTime.parse("2012-01-14 10:01:00 Z"), # -> impediment
            :updated_at => DateTime.parse("2012-01-18 10:01:00 Z"), # -> impediment
            :current_state => "started", #
            :accepted? => false,
            :activities => []),

        # ICEBOX
        double(
            :story_type => Story::FEATURE,
            :created_at => DateTime.parse("2012-01-01 00:01:00 Z"), # iteration 0
            :updated_at => DateTime.parse("2012-01-01 00:01:00 Z"), # iteration 0
            :current_state => "unscheduled",
            :accepted? => false,
            :activities => []),

        # BACKLOG
        double(
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

        #row_values(rows, 0).should == ["Features", 19] #1d + 7 + 4
        row_values(rows, 1).should == ["Bugs", 8]      #1d
        row_values(rows, 2).should == ["Chores", 32]   #3d4h + 4

      end
    end

    #describe "charts that can be filtered" do
    #
    #  let(:story_filter) {Story::ALL_STORY_TYPES}
    #  let(:chart) {@chart_presenter.send(chart_method, story_filter)}
    #
    #  describe "#discovery_and_acceptance_chart" do
    #    let(:chart_method) {"discovery_and_acceptance_chart"}
    #
    #    it_should_behave_like "a chart generation method"
    #
    #    context "filtering by story type" do
    #
    #      let(:story_filter) {[Story::BUG] }
    #
    #      it "accepts an array of the story types to be filtered" do
    #        rows = chart.data_table.rows
    #
    #        rows.length.should == 5
    #        # I   Bc Ba
    #        filter_tooltips(rows, 0).should == ["0", 0, 0]
    #        filter_tooltips(rows, 1).should == ["1", 1, 0]
    #        filter_tooltips(rows, 2).should == ["2", 0, 0]
    #        filter_tooltips(rows, 3).should == ["3", 1, 0]
    #        filter_tooltips(rows, 4).should == ["4", 0, 0]
    #      end
    #    end
    #
    #    it "produces an area chart for the discovery and subsequent acceptance of stories" do
    #      rows = chart.data_table.rows
    #
    #      rows.length.should == 5
    #      # I   Fc Fa Bc Ba Cc Ca
    #      filter_tooltips(rows, 0).should == ["0", 1, 0, 0, 0, 0, 0]
    #      filter_tooltips(rows, 1).should == ["1", 1, 1, 1, 0, 0, 0]
    #      filter_tooltips(rows, 2).should == ["2", 1, 1, 0, 0, 0, 0]
    #      filter_tooltips(rows, 3).should == ["3", 0, 0, 1, 0, 1, 0]
    #      filter_tooltips(rows, 4).should == ["4", 0, 0, 0, 0, 0, 0]
    #    end
    #  end
    #
    #  describe "#acceptance_days_by_iteration_chart" do
    #    let(:chart_method) {"acceptance_days_by_iteration_chart"}
    #
    #    it_should_behave_like "a chart generation method"
    #
    #    context "filtering by story type" do
    #      let(:story_filter) {[Story::FEATURE]}
    #
    #      it "accepts an array of story types to filter" do
    #        rows = chart.data_table.rows
    #
    #        rows.length.should == 2
    #        # I  Fd
    #        filter_tooltips(rows, 0).should == [1, 25]
    #        filter_tooltips(rows, 1).should == [2, 06]
    #      end
    #    end
    #
    #    it "produces a scatter chart of accepted stories per iteration" do
    #      rows = chart.data_table.rows
    #
    #      rows.length.should == 2
    #      # I  Fd   Bd   Cd
    #      filter_tooltips(rows, 0).should == [1, 25, nil, nil]
    #      filter_tooltips(rows, 1).should == [2, 06, nil, nil]
    #    end
    #  end
    #
    #  describe "#acceptance_by_days_chart" do
    #    let(:chart_method) {"acceptance_by_days_chart"}
    #
    #    it_should_behave_like "a chart generation method"
    #
    #    context "filtering by story type" do
    #      let(:story_filter) {[Story::FEATURE, Story::CHORE]}
    #
    #      it "accepts an array of story types to filter" do
    #        rows = chart.data_table.rows
    #
    #        rows.length.should == 26
    #        # D    Fd Cd
    #        filter_tooltips(rows, 6).should  == ["6",  1, 0]
    #        filter_tooltips(rows, 25).should == ["25", 1, 0]
    #      end
    #    end
    #
    #    it "produces a bar chart for the time to acceptance of each story" do
    #      rows = chart.data_table.rows
    #
    #      rows.length.should == 26
    #      # D    Fd Bd Cd
    #      filter_tooltips(rows, 6).should  == ["6",  1, 0, 0]
    #      filter_tooltips(rows, 25).should == ["25", 1, 0, 0]
    #    end
    #  end
    #end
  end


end