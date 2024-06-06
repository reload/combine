require "./spec_helper"
require "../../src/models/task.cr"

describe Task do
  Spec.before_each do
    Task.clear
  end

  it "returns last_updated_at" do
    Task.last_updated_at.should be_nil

    Task.create!(
      {id: 123_i64,
       name: "The name",
       billable_by_default: false,
       created_at: Time.utc(2024, 6, 2, 21, 27, 0),
       updated_at: Time.utc(2024, 6, 2, 21, 27, 0),
      }
    )

    Task.last_updated_at.should eq Time.utc(2024, 6, 2, 21, 27, 0)
  end
end
