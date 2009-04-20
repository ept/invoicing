class CreateInvoicingTaxable < ActiveRecord::Migration
  def self.up
    create_table :tax_rates do |t|
      t.string :description
      t.decimal :rate, :precision => 20, :scale => 4
      t.datetime :valid_from, :null => false
      t.datetime :valid_until
      t.integer :replaced_by_id
      t.boolean :is_default
      t.timestamps
    end
    
    TaxRate.reset_column_information
    TaxRate.create :description => 'Standard rate VAT', :rate => BigDecimal('0.175'),
      :valid_from => '1991-04-01 00:00:00', :valid_until => '2008-12-01 00:00:00',
      :replaced_by_id => 4, :is_default => true
    TaxRate.create :description => 'Reduced rate VAT', :rate => BigDecimal('0.05'),
      :valid_from => '1991-04-01 00:00:00', :is_default => false
    TaxRate.create :description => 'Zero rate VAT', :rate => BigDecimal('0'),
      :valid_from => '1991-04-01 00:00:00', :is_default => false
    TaxRate.create :description => 'Standard rate VAT', :rate => BigDecimal('0.15'),
      :valid_from => '2008-12-01 00:00:00', :is_default => true
      
    add_column :line_items, :tax_rate_id, :integer
  end

  def self.down
    remove_column :line_items, :tax_rate_id
    drop_table :tax_rates
  end
end
