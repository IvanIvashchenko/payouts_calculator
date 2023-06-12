class AddPayoutFrequencyEnum < ActiveRecord::Migration[6.1]
  def up
    execute <<~SQL
      CREATE TYPE payout_frequency AS ENUM ('daily', 'weekly');
    SQL
  end

  def down
    execute <<~SQL
      DROP TYPE payout_frequency;
    SQL
  end
end
