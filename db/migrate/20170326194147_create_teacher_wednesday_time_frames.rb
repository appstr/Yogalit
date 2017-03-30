class CreateTeacherWednesdayTimeFrames < ActiveRecord::Migration
  def change
    create_table :teacher_wednesday_time_frames do |t|
      t.belongs_to :teacher, index: true
      t.int8range :time_range
      t.timestamps null: false
    end
  end
end