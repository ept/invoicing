class CreateInvoicingLedger < ActiveRecord::Migration
  def self.up
    create_table :<%= name_details[:ledger_item][:underscore_plural] %> do |t|
      t.string :type
      t.integer :sender_id
      t.integer :recipient_id
      t.datetime :issue_date
      t.string :currency, :limit => 3, :null => false<%= options[:currency] ? ", :default => '#{options[:currency]}'" : '' %>
      t.decimal :total_amount, :precision => 20, :scale => 4
      t.decimal :tax_amount, :precision => 20, :scale => 4
      t.string :status, :limit => 20
<% if options[:identifier] -%>
      t.string :identifier, :limit => 50
<% end -%>
<% if options[:description] -%>
      t.string :description
<% end -%>
<% if options[:period] -%>
      t.datetime :period_start
      t.datetime :period_end
<% end -%>
<% if options[:uuid] -%>
      t.string :uuid, :limit => 40
<% end -%>
<% if options[:due_date] -%>
      t.datetime :due_date
<% end -%>
<% if options[:timestamps] -%>
      t.timestamps
<% end -%>
    end
    
    create_table :<%= name_details[:line_item][:underscore_plural] %> do |t|
      t.string :type
      t.references :<%= name_details[:ledger_item][:underscore_singular] %>
      t.decimal :net_amount, :precision => 20, :scale => 4
      t.decimal :tax_amount, :precision => 20, :scale => 4
<% if options[:description] -%>
      t.string :description
<% end -%>
<% if options[:uuid] -%>
      t.string :uuid, :limit => 40
<% end -%>
<% if options[:tax_point] -%>
      t.datetime :tax_point
<% end -%>
<% if options[:quantity] -%>
      t.decimal :quantity, :precision => 20, :scale => 4
<% end -%>
<% if options[:creator] -%>
      t.integer :creator_id
<% end -%>
<% if options[:timestamps] -%>
      t.timestamps
<% end -%>
    end
  end 

  def self.down
    drop_table :<%= name_details[:line_item][:underscore_plural] %>
    drop_table :<%= name_details[:ledger_item][:underscore_plural] %>
  end
end
