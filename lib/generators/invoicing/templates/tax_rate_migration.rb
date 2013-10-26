class CreateInvoicingTaxable < ActiveRecord::Migration
  def change
    create_table :invoicing_tax_rates do |t|
      t.string   :description
      t.decimal  :rate,           precision: 20, scale: 4
      t.datetime :valid_from,     null: false
      t.datetime :valid_until
      t.integer  :replaced_by_id
      t.boolean  :is_default

      t.timestamps
    end
  end
end
