class ColumnsController < ApplicationController
  def create
    @master_sprint = MasterSprint.new master_sprint_params

    if @master_sprint.save
      @sprint = @master_sprint.sprint
      @activities = @sprint.activities
      @assignees = @sprint.assignees
      @total_lost_hour = @sprint.time_logs.size
      @total_time_log = @sprint.log_works.size
      @total_master_sprint = @sprint.master_sprints.size
    end

    respond_to do |format|
      format.js
    end
  end



  private
  def master_sprint_params
    params.require(:master_sprint).permit :sprint_id, :date
  end
end
