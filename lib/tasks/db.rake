namespace :db do
  desc "Remaking data"
  task remake_data: :environment do
    Rake::Task["db:migrate:reset"].invoke

    puts "Creating Manager"
    user = Fabricate :user, role: 2, email: "chu.anh.tuan@framgia.com",
      name: "Chu Anh Tuan"

    puts "Creating project"
    project = Fabricate :project, manager_id: user.id

    puts "Creating sprint for each project"
    2.times do
      Fabricate :sprint, project_id: project.id
    end

    puts "Creating product backlog"
    5.times do
      Fabricate :product_backlog, project_id: project.id, sprint_id: Sprint.first.id
    end

    puts "Creating member"
    user_hash = {
      "Nguyen Binh Dieu": "nguyen.binh.dieu",
      "Hoang Thi Nhung": "hoang.thi.nhung",
      "Luu Thi Thom": "luu.thi.thom",
      "Bui Thi Phan": "bui.thi.phan",
      "Nguyen Thi Phuong B": "nguyen.thi.phuongb",
      "Bui Van Duong": "bui.van.duong"
    }
    user_hash.each do |key, value|
      user = Fabricate :user, name: key, email: value+"@framgia.com"
    end

    puts "Add asignee to project 1"
    User.all.each do |user|
      Fabricate :assignee, user_id: user.id, project_id: project.id,
        sprint_id: nil, work_hour: 0
    end

    puts "Add asignee to sprints 1"
    User.all.each do |user|
      as = Fabricate :assignee, user_id: user.id, project_id: nil,
        sprint_id: Sprint.first.id, work_hour: 8
      as.time_logs.each do |time_log|
        time_log.update_attributes lost_hour: 1
      end
    end

    puts "Creating phase"
    ["Design", "Developing", "Testing"].each do |phase|
      Fabricate :phase, phase_name: phase
    end

    puts "Chose phase for project"
    Fabricate :project_phase, project_id: project.id, phase_id: 2

    puts "Creating tasks for the first sprint of project 1"
    Sprint.first.assignees.each do |assignee|
      ac = Fabricate :task, user_id: assignee.user.id, sprint_id: Sprint.first.id,
        product_backlog_id: ProductBacklog.first.id
      start_log_work = 8
      ac.log_works.each do |log_work|
        if start_log_work > 0
          log_work.update_attributes remaining_time: start_log_work - 1
          start_log_work -= 1
        else
          log_work.update_attributes remaining_time: start_log_work
        end
      end
    end

    puts "Creating item performances"
    Fabricate :item_performance, name: "Scope", chart_type: 0
    Fabricate :item_performance, name: "Time", chart_type: 1
    Fabricate :item_performance, name: "Cost", chart_type: 1
    Fabricate :item_performance, name: "Quanlity", chart_type: 0
    Fabricate :item_performance, name: "Line of code", chart_type: nil
    Fabricate :item_performance, name: "Test case", chart_type: nil

    puts "Add item performances to phase"
    ItemPerformance.all.each do |item|
      Fabricate :phase_item, phase_id: 2, item_performance_id: item.id, visible: true
    end

    puts "Create work performances value"
    Task.all.each do |task|
      if task.user_id
        assignee = project.assignees.sample
        performance_value = Random.rand(50 .. 70)
        phase_item = project.phase_items.sample

        Sprint.first.master_sprints.each do |day|
          if phase_item.item_performance.burn_up?
            performance_value += Random.rand(3 .. 6)
          elsif phase_item.item_performance.burn_down?
            performance_value -= Random.rand(3 .. 6)
            performance_value = performance_value >= 0 ? performance_value : 0
          else
            performance_value = Random.rand(30 .. 70)
          end

          Fabricate :work_performance, phase_id: phase_item.phase_id, sprint_id: 1,
            master_sprint_id: day.id, user_id: task.user_id,
            item_performance_id: phase_item.item_performance_id,
            task_id: task.id, performance_value: performance_value
        end
      end
    end

    puts "Success remake data"
  end
end
