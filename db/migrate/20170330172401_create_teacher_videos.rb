class CreateTeacherVideos < ActiveRecord::Migration
  def change
    create_table :teacher_videos do |t|
      t.belongs_to :teacher, index: true
      t.timestamps null: false
    end
  end
end
