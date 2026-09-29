# Things 3 sample data. Idempotent: wipes and reseeds. Development only.
return if Rails.env.test?

def reset!
  [Tagging, ChecklistItem, Tag, Task, Heading, Project, Area, User].each(&:delete_all)
end

reset!

user = User.create!(
  email: "demo@things.local",
  password: "things3",
  password_confirmation: "things3",
  locale: "en",
)

today = Date.current

tags = {
  home: Tag.create!(name: "Home"),
  work: Tag.create!(name: "Work"),
  errand: Tag.create!(name: "Errand"),
  phone: Tag.create!(name: "Phone"),
  email: Tag.create!(name: "Email"),
  travel: Tag.create!(name: "Travel"),
  reading: Tag.create!(name: "Reading"),
}

areas = {
  personal: Area.create!(name: "Personal", position: 0),
  work: Area.create!(name: "Work", position: 1),
}

projects = {
  house: Project.create!(name: "House", color: "#4a7cf5", notes: "Everything about the apartment", area: areas[:personal], position: 0),
  qc: Project.create!(name: "Quarter Close", color: "#f0923f", notes: "Wrap up Q3 and set up Q4", area: areas[:work], position: 1),
  side: Project.create!(name: "Side Project", color: "#7c5cd6", notes: "The coffee subscription idea", area: nil, position: 2),
  trip: Project.create!(name: "Trip to Chiang Mai", color: "#2db8a6", notes: "Long weekend in October", area: areas[:personal], position: 3),
}

def make_task(user, attrs = {})
  tags = attrs.delete(:tags) || []
  checklist = attrs.delete(:checklist) || []
  task = user.tasks.create!(attrs)
  tags.each { |t| task.tags << t }
  checklist.each_with_index do |(title, done), i|
    task.checklist_items.create!(title: title, completed: done, position: i)
  end
  task
end

pos = 0
next_pos = -> { pos += 1 }

# ---- Today ----
make_task(user, title: "Buy groceries", notes: "Milk, eggs, sourdough, coffee beans",
          when_date: today, reminder_at: "09:00", tags: [tags[:home]], position: next_pos.call)
make_task(user, title: "Call the bank about the credit card",
          when_date: today, reminder_at: "10:30", tags: [tags[:phone]], position: next_pos.call)
make_task(user, title: "Finish quarterly report", notes: "Q3 numbers + executive summary",
          checklist: [["Pull Q3 metrics", true], ["Write summary", false], ["Review with Dana", false]],
          when_date: today, deadline_date: today, tags: [tags[:work]], project: projects[:qc], position: next_pos.call)
make_task(user, title: "Team standup", when_date: today, reminder_at: "14:00", tags: [tags[:work]], position: next_pos.call)
make_task(user, title: "Reply to Sarah about the venue", when_date: today, tags: [tags[:email]], position: next_pos.call)
make_task(user, title: "Pick up dry cleaning", when_date: today, tags: [tags[:errand]], position: next_pos.call)
make_task(user, title: "Read 20 pages of Dune", when_date: today, evening: true, tags: [tags[:reading]], position: next_pos.call)
make_task(user, title: "Water the plants", when_date: today, evening: true, tags: [tags[:home]], position: next_pos.call)

# ---- Inbox ----
make_task(user, title: "Research tents for the camping trip", tags: [tags[:travel]], position: next_pos.call)
make_task(user, title: "Book dentist appointment", position: next_pos.call)
make_task(user, title: "Renew passport", deadline_date: today + 47, position: next_pos.call)
make_task(user, title: "Send wedding photos to Aunt May", position: next_pos.call)

# ---- House ----
make_task(user, title: "Replace the hallway light bulb", notes: "LED, warm white 2700K", project: projects[:house], position: next_pos.call)
maintenance = Heading.create!(project: projects[:house], name: "Maintenance", position: 0)
make_task(user, title: "Fix the leaky kitchen faucet", project: projects[:house], heading: maintenance, position: next_pos.call)
make_task(user, title: "Deep clean the balcony", project: projects[:house], someday: true, position: next_pos.call)
make_task(user, title: "Get a ladder for the storage room", project: projects[:house], someday: true, position: next_pos.call)

# ---- Quarter Close ----
make_task(user, title: "Archive Q3 invoices", project: projects[:qc], position: next_pos.call)
make_task(user, title: "Update the roadmap deck", notes: "Include the hiring plan", project: projects[:qc], position: next_pos.call)

# ---- Side Project ----
make_task(user, title: "Sketch onboarding screens", project: projects[:side], position: next_pos.call)
make_task(user, title: "Write the pitch deck outline", project: projects[:side], someday: true, position: next_pos.call)
make_task(user, title: "Register the domain name", project: projects[:side], position: next_pos.call)

# ---- Trip to Chiang Mai ----
make_task(user, title: "Book flights", deadline_date: today + 3, project: projects[:trip], position: next_pos.call)
make_task(user, title: "Reserve the Airbnb", notes: "Old city, 2 nights", project: projects[:trip], position: next_pos.call)
make_task(user, title: "Pack warm clothes for the mountains", project: projects[:trip], someday: true, position: next_pos.call)
make_task(user, title: "Make a list of cafes", notes: "Ask Nim for recommendations", project: projects[:trip], someday: true, position: next_pos.call)

# ---- Upcoming ----
make_task(user, title: "Team offsite planning", when_date: today + 1, tags: [tags[:work]], project: projects[:qc], position: next_pos.call)
make_task(user, title: "Yoga class", when_date: today + 2, reminder_at: "18:30", position: next_pos.call)
make_task(user, title: "Dentist appointment", when_date: today + 7, reminder_at: "08:00", position: next_pos.call)
make_task(user, title: "Submit tax documents", when_date: today + 11, deadline_date: today + 11, tags: [tags[:work]], position: next_pos.call)
make_task(user, title: "Mom's birthday", when_date: today + 13, tags: [tags[:home]], position: next_pos.call)
make_task(user, title: "Flight to Chiang Mai", when_date: today + 18, reminder_at: "06:45", tags: [tags[:travel]], project: projects[:trip], position: next_pos.call)

# ---- Someday, loose ----
make_task(user, title: "Learn to sail", someday: true, tags: [tags[:travel]], position: next_pos.call)
make_task(user, title: "Restore grandpa's bicycle", someday: true, position: next_pos.call)
make_task(user, title: "Road trip through Patagonia", someday: true, tags: [tags[:travel]], position: next_pos.call)

# ---- Logbook ----
make_task(user, title: "Pay electricity bill", status: :completed, completed_at: 2.days.ago, position: next_pos.call)
make_task(user, title: "Send Mom the recipe book", status: :completed, completed_at: 3.days.ago, position: next_pos.call)
make_task(user, title: "Renew library membership", status: :completed, completed_at: 8.days.ago, position: next_pos.call)
make_task(user, title: "Buy birthday gift for Nim", status: :completed, completed_at: 9.days.ago, position: next_pos.call)
make_task(user, title: "Set up the new espresso machine", notes: "26 g in, 45 s, 1:2 ratio",
          status: :completed, completed_at: 10.days.ago, position: next_pos.call)

puts "Seeded: #{User.count} user, #{Area.count} areas, #{Project.count} projects, #{Tag.count} tags, #{Task.count} tasks."
