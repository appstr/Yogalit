class TeacherTuesdayTimeFramesController < ApplicationController
  before_action :authenticate_user!

  def new
    @teacher = Teacher.where(user_id: current_user).first

    @teacher_tuesday_time_frame = TeacherTuesdayTimeFrame.new

    teacher = Teacher.where(user_id: current_user).first
    @teacher_tuesday_time_frames = TeacherTuesdayTimeFrame.where(teacher_id: teacher)
  end

  def create
    teacher = Teacher.where(user_id: current_user).first
    split_start_time
    split_end_time
    if end_less_than_start?(teacher)
      flash[:notice] = "End time cannot be less than start time."
      return redirect_to request.referrer
    end
    if time_frame_taken?(teacher)
      flash[:notice] = "Time frame given interferes with a previous time frame."
      return redirect_to request.referrer
    end
    Time.zone = teacher.timezone
    teacher_tuesday_time_frame = TeacherTuesdayTimeFrame.new
    teacher_tuesday_time_frame[:time_range] = (Time.zone.local(2017, 03, 28, @start_hour, @start_minute, 00)..Time.zone.local(2017, 03, 28, @end_hour, @end_minute, 00))
    teacher_tuesday_time_frame[:teacher_id] = teacher[:id]
    if teacher_tuesday_time_frame.save!
      Teacher.qualifies_for_search?(current_user)
      if params[:commit] == "Save and Add Another TimeFrame"
        flash[:notice] = "TimeFrame saved successfully!"
        path = request.referrer
      else
        flash[:notice] = "TimeFrame saved successfully!"
        path = teachers_path
      end
    else
      flash[:notice] = "TimeFrame did not save successfully."
      path = request.referrer
    end
    return redirect_to path
  end

  def destroy
    TeacherTuesdayTimeFrame.find(params[:id]).delete
    Teacher.qualifies_for_search?(current_user)
    return redirect_to request.referrer
  end

  private

  def end_less_than_start?(teacher)
    if Time.zone.local(2017, 03, 28, @start_hour, @start_minute, 00).in_time_zone(teacher[:timezone]) > Time.zone.local(2017, 03, 28, @end_hour, @end_minute, 00).in_time_zone(teacher[:timezone])
      return true
    else
      return false
    end
  end

  def time_frame_taken?(teacher)
    time_frames = TeacherTuesdayTimeFrame.where(teacher_id: teacher)
    return false if time_frames.blank?
    time_frames.each do |tf|
      if (tf[:time_range].first..tf[:time_range].last).include? Time.zone.local(2017, 03, 28, @start_hour, @start_minute, 00).in_time_zone(teacher[:timezone]).to_i
        return true
      elsif (Time.zone.local(2017, 03, 28, @start_hour, @start_minute, 00).in_time_zone(teacher[:timezone]).to_i..Time.zone.local(2017, 03, 28, @end_hour, @end_minute, 00).in_time_zone(teacher[:timezone]).to_i).include? tf[:time_range].first
        return true
      end
    end
    return false
  end

  def teacher_tuesday_time_frame_params
    params.require(:teacher_tuesday_time_frame).permit(:teacher_id, :time_range)
  end
end
