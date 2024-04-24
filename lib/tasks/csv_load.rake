require 'csv'

namespace :csv_load do
  desc "Imports customers data"
  task :customers => :environment do
    Customer.destroy_all
      CSV.foreach('db/data/customers.csv', :headers => true) do |row|
        Customer.create!(row.to_hash)
      end
      ActiveRecord::Base.connection.reset_pk_sequence!('customers')
      puts 'Customers successful'
    end
  
  desc "Imports invoice_items data"
  task :invoice_items => :environment do    
    InvoiceItem.destroy_all
      CSV.foreach('db/data/invoice_items.csv', :headers => true) do |row|
        InvoiceItem.create!(row.to_hash)
      end
      ActiveRecord::Base.connection.reset_pk_sequence!('invoice_items')
      puts 'InvoiceItems successful'
    end

  desc "Imports invoices data"
  task :invoices => :environment do    
    Invoice.destroy_all
      CSV.foreach('db/data/invoices.csv', :headers => true) do |row|
        Invoice.create!(row.to_hash)
      end
      ActiveRecord::Base.connection.reset_pk_sequence!('invoices')
      puts 'Invoices successful'
    end

  desc "Imports items data"
  task :items => :environment do    
    Item.destroy_all
      CSV.foreach('db/data/items.csv', :headers => true) do |row|
        Item.create!(row.to_hash)
      end
      ActiveRecord::Base.connection.reset_pk_sequence!('items')
      puts 'Items successful'
    end
  
  desc "Imports merchants data"
  task :merchants => :environment do    
    Merchant.destroy_all
      CSV.foreach('db/data/merchants.csv', :headers => true) do |row|
        Merchant.create!(row.to_hash)
      end
      ActiveRecord::Base.connection.reset_pk_sequence!('merchants')
      puts 'Merchants successful'
    end

  desc "Imports transactions data"
  task :transactions => :environment do    
    Transaction.destroy_all
      CSV.foreach('db/data/transactions.csv', :headers => true) do |row|
        Transaction.create!(row.to_hash)
      end
      ActiveRecord::Base.connection.reset_pk_sequence!('transactions')
      puts 'Transactions successful'
    end

    task :all => [:merchants,:customers, :invoices, :items, :invoice_items, :transactions]

    puts 'Seeding successful'
end
