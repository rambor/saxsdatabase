# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140903201524) do

  create_table "authors", :force => true do |t|
    t.string   "lastname",   :default => "Rambo", :null => false
    t.string   "initials",   :default => "R.P.",  :null => false
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  create_table "authors_experiments", :id => false, :force => true do |t|
    t.integer "experiment_id",                :null => false
    t.integer "author_id",     :default => 0, :null => false
  end

  create_table "bunch_results", :force => true do |t|
    t.integer  "experiment_id",                                                  :null => false
    t.string   "spacegroup",                                   :default => "P1", :null => false
    t.integer  "volume",                                                         :null => false
    t.integer  "sig_volume",                                                     :null => false
    t.decimal  "chi_square",     :precision => 3, :scale => 1
    t.decimal  "sig_chi_square", :precision => 3, :scale => 1
    t.decimal  "Rg",             :precision => 5, :scale => 2
    t.decimal  "sig_Rg",         :precision => 5, :scale => 2
    t.integer  "Dmax"
    t.integer  "sig_Dmax"
    t.decimal  "NSD",            :precision => 4, :scale => 2
    t.decimal  "sig_NSD",        :precision => 4, :scale => 2
    t.string   "data_directory",                                                 :null => false
    t.datetime "created_on",                                                     :null => false
    t.datetime "updated_on",                                                     :null => false
  end

  create_table "credo_results", :force => true do |t|
    t.integer  "experiment_id",                                                  :null => false
    t.string   "spacegroup",                                   :default => "P1", :null => false
    t.integer  "volume",                                                         :null => false
    t.integer  "sig_volume",                                                     :null => false
    t.decimal  "chi_square",     :precision => 3, :scale => 1
    t.decimal  "sig_chi_square", :precision => 3, :scale => 1
    t.decimal  "Rg",             :precision => 5, :scale => 2
    t.decimal  "sig_Rg",         :precision => 5, :scale => 2
    t.integer  "Dmax"
    t.integer  "sig_Dmax"
    t.decimal  "NSD",            :precision => 4, :scale => 2
    t.decimal  "sig_NSD",        :precision => 4, :scale => 2
    t.string   "data_directory",                                                 :null => false
    t.datetime "created_on",                                                     :null => false
    t.datetime "updated_on",                                                     :null => false
  end

  create_table "dammin_results", :force => true do |t|
    t.integer  "experiment_id",                                                                         :null => false
    t.string   "spacegroup",                                                          :default => "P1", :null => false
    t.decimal  "nsd",                                   :precision => 5, :scale => 4
    t.decimal  "sig_NSD",                               :precision => 5, :scale => 4
    t.string   "data_directory",                                                                        :null => false
    t.datetime "created_at",                                                                            :null => false
    t.datetime "updated_at",                                                                            :null => false
    t.string   "single_model_filename",  :limit => 200,                                                 :null => false
    t.string   "average_model_filename", :limit => 200,                                                 :null => false
    t.integer  "number_in_average",                                                                     :null => false
    t.string   "subcomb_model",          :limit => 200
  end

  create_table "ensembles", :force => true do |t|
    t.integer  "experiment_id",                                                        :null => false
    t.decimal  "score",                                  :precision => 3, :scale => 1
    t.string   "fit_filename",            :limit => 100,                               :null => false
    t.string   "diagnostic_file_name",    :limit => 100,                               :null => false
    t.string   "selection_method",                                                     :null => false
    t.string   "simulation_method",                                                    :null => false
    t.string   "simulation_algorithm",                                                 :null => false
    t.integer  "ensemble_size"
    t.datetime "created_at",                                                           :null => false
    t.datetime "updated_at",                                                           :null => false
    t.string   "data_directory",                                                       :null => false
    t.integer  "member_size",                                                          :null => false
    t.string   "scoring_function"
    t.string   "diagnostic_content_type"
    t.integer  "diagnostic_file_size"
    t.text     "figure_legend"
  end

  create_table "experimental_links", :force => true do |t|
    t.integer "experiment_id", :null => false
    t.integer "link_to_id",    :null => false
  end

  add_index "experimental_links", ["experiment_id"], :name => "index_experimental_links_on_experiment_id"
  add_index "experimental_links", ["link_to_id"], :name => "index_experimental_links_on_link_to_id"

  create_table "experiments", :force => true do |t|
    t.decimal  "pH",                                    :precision => 4, :scale => 2, :default => 7.0
    t.integer  "salt_concentration",                                                  :default => 100,         :null => false
    t.string   "salt",                                                                :default => "NaCl",      :null => false
    t.string   "buffer",                 :limit => 30,                                :default => "Tris-Base", :null => false
    t.text     "description"
    t.string   "data_directory",         :limit => 100,                                                        :null => false
    t.string   "title",                  :limit => 200,                                                        :null => false
    t.integer  "dmax"
    t.decimal  "rg",                                    :precision => 5, :scale => 2
    t.decimal  "rg_real",                               :precision => 5, :scale => 2
    t.decimal  "sig_Rg_real",                           :precision => 5, :scale => 2,                          :null => false
    t.decimal  "io",                                    :precision => 9, :scale => 2
    t.decimal  "sig_Io",                                :precision => 6, :scale => 2,                          :null => false
    t.integer  "v_porod"
    t.integer  "number_of_genes",                                                     :default => 1,           :null => false
    t.string   "iofq_file_name",         :limit => 100,                                                        :null => false
    t.integer  "author_id",                                                           :default => 0,           :null => false
    t.text     "source_location"
    t.datetime "created_at",                                                                                   :null => false
    t.datetime "updated_at",                                                                                   :null => false
    t.decimal  "sig_Rg",                                :precision => 5, :scale => 2,                          :null => false
    t.string   "divalent",                                                            :default => "MgCl2",     :null => false
    t.decimal  "divalent_concentration",                :precision => 5, :scale => 1, :default => 0.0,         :null => false
    t.string   "additives"
    t.boolean  "status",                                                              :default => false,       :null => false
    t.string   "verification_key"
    t.string   "email",                                                                                        :null => false
    t.string   "ip_address"
    t.integer  "io_molecular_weight"
    t.decimal  "temp",                                  :precision => 4, :scale => 1, :default => 25.0,        :null => false
    t.string   "pofr_file_name",         :limit => 100,                                                        :null => false
    t.text     "publication"
    t.text     "experimental_details"
    t.boolean  "rna",                                                                 :default => false
    t.boolean  "dna",                                                                 :default => false
    t.boolean  "protein",                                                             :default => false
    t.boolean  "membrane",                                                            :default => false
    t.decimal  "porod_exponent",                        :precision => 3, :scale => 2
    t.decimal  "volume_of_correlation",                 :precision => 8, :scale => 1
    t.string   "bioisis_id",             :limit => 6
    t.boolean  "nanoparticle",                                                        :default => false
    t.decimal  "qmin",                                  :precision => 5, :scale => 4
    t.decimal  "qmax",                                  :precision => 5, :scale => 4
  end

  add_index "experiments", ["bioisis_id"], :name => "index_experiments_on_bioisis_id", :unique => true

  create_table "experiments_expgenes", :id => false, :force => true do |t|
    t.integer "experiment_id",                :null => false
    t.integer "expgene_id",    :default => 0, :null => false
  end

  create_table "experiments_genes", :id => false, :force => true do |t|
    t.integer "experiment_id",                :null => false
    t.integer "gene_id",       :default => 0, :null => false
  end

  create_table "expgenes", :force => true do |t|
    t.integer  "gene_id"
    t.text     "experimental_sequence",                                                              :null => false
    t.integer  "exp_mw",                                                                             :null => false
    t.decimal  "pI",                                  :precision => 3, :scale => 1, :default => 7.5, :null => false
    t.text     "annotation"
    t.datetime "created_at",                                                                         :null => false
    t.datetime "updated_at",                                                                         :null => false
    t.string   "accession"
    t.string   "abbr_name",             :limit => 10
  end

  create_table "expgenes_genes", :force => true do |t|
    t.integer  "expgene_id",                :null => false
    t.integer  "gene_id",    :default => 0, :null => false
    t.datetime "created_on",                :null => false
    t.datetime "updated_on",                :null => false
  end

  create_table "forums", :force => true do |t|
    t.string  "name"
    t.string  "description"
    t.integer "topics_count",     :default => 0
    t.integer "posts_count",      :default => 0
    t.integer "position"
    t.text    "description_html"
  end

  create_table "gasbor_results", :force => true do |t|
    t.integer  "experiment_id",                                                                         :null => false
    t.string   "spacegroup",                                                          :default => "P1", :null => false
    t.decimal  "chi_square",                            :precision => 6, :scale => 4
    t.decimal  "sig_chi_square",                        :precision => 6, :scale => 4
    t.decimal  "nsd",                                   :precision => 4, :scale => 2
    t.decimal  "sig_NSD",                               :precision => 4, :scale => 2
    t.string   "data_directory",                                                                        :null => false
    t.datetime "created_at",                                                                            :null => false
    t.datetime "updated_at",                                                                            :null => false
    t.string   "single_model_filename",  :limit => 200,                                                 :null => false
    t.string   "average_model_filename", :limit => 200,                                                 :null => false
    t.integer  "number_in_average",                                                                     :null => false
    t.string   "subcomb_model",          :limit => 200
  end

  create_table "genes", :force => true do |t|
    t.integer  "organism_id"
    t.integer  "accession"
    t.string   "locus_name"
    t.string   "uniprot"
    t.text     "protein_sequence",                               :null => false
    t.integer  "theoretical_mw",                                 :null => false
    t.decimal  "pI",               :precision => 3, :scale => 2
    t.text     "annotation"
    t.integer  "gene_start",                                     :null => false
    t.integer  "gene_end",                                       :null => false
    t.datetime "created_at",                                     :null => false
    t.datetime "updated_at",                                     :null => false
  end

  create_table "logged_exceptions", :force => true do |t|
    t.string   "exception_class"
    t.string   "controller_name"
    t.string   "action_name"
    t.text     "message"
    t.text     "backtrace"
    t.text     "environment"
    t.text     "request"
    t.datetime "created_at"
  end

  create_table "moderatorships", :force => true do |t|
    t.integer "forum_id"
    t.integer "user_id"
  end

  add_index "moderatorships", ["forum_id"], :name => "index_moderatorships_on_forum_id"

  create_table "monitorships", :force => true do |t|
    t.integer "topic_id"
    t.integer "user_id"
    t.boolean "active",   :default => true
  end

  create_table "news", :force => true do |t|
    t.integer  "user_id",      :null => false
    t.string   "title"
    t.text     "journal_info"
    t.text     "abstract"
    t.text     "notes"
    t.string   "category"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "link"
  end

  create_table "no_models", :force => true do |t|
    t.integer  "experiment_id",                      :null => false
    t.text     "description",                        :null => false
    t.string   "figure_file_name",    :limit => 100
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.string   "figure_content_type"
    t.integer  "figure_file_size"
    t.string   "data_directory"
  end

  create_table "organisms", :force => true do |t|
    t.string   "species",                   :null => false
    t.string   "abbreviation", :limit => 8, :null => false
    t.datetime "created_on",                :null => false
    t.datetime "updated_on",                :null => false
  end

  create_table "posts", :force => true do |t|
    t.integer  "user_id"
    t.integer  "topic_id"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "forum_id"
    t.text     "body_html"
  end

  add_index "posts", ["forum_id", "created_at"], :name => "index_posts_on_forum_id"
  add_index "posts", ["topic_id", "created_at"], :name => "index_posts_on_topic_id"
  add_index "posts", ["user_id", "created_at"], :name => "index_posts_on_user_id"

  create_table "roles", :force => true do |t|
    t.string   "role"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  create_table "sasreff_results", :force => true do |t|
    t.integer  "experiment_id",                                                  :null => false
    t.string   "spacegroup",                                   :default => "P1", :null => false
    t.integer  "volume",                                                         :null => false
    t.integer  "sig_volume",                                                     :null => false
    t.decimal  "chi_square",     :precision => 3, :scale => 1
    t.decimal  "sig_chi_square", :precision => 3, :scale => 1
    t.decimal  "Rg",             :precision => 5, :scale => 2
    t.decimal  "sig_Rg",         :precision => 5, :scale => 2
    t.integer  "Dmax"
    t.integer  "sig_Dmax"
    t.decimal  "NSD",            :precision => 4, :scale => 2
    t.decimal  "sig_NSD",        :precision => 4, :scale => 2
    t.string   "data_directory",                                                 :null => false
    t.datetime "created_on",                                                     :null => false
    t.datetime "updated_on",                                                     :null => false
  end

  create_table "scatter_downloads", :force => true do |t|
    t.string   "institution"
    t.string   "country"
    t.string   "ip_address"
    t.string   "status"
    t.string   "version"
    t.integer  "user_id"
    t.string   "pi"
    t.boolean  "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "scatter_updates", :force => true do |t|
    t.text     "comments"
    t.string   "version"
    t.string   "title"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
    t.string   "zipfile_file_name"
    t.string   "zipfile_content_type"
    t.integer  "zipfile_file_size"
    t.datetime "zipfile_updated_at"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id"
    t.text     "data"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  add_index "sessions", ["session_id"], :name => "sessions_session_id_index"

  create_table "structural_models", :force => true do |t|
    t.integer  "experiment_id",                                                                               :null => false
    t.decimal  "chi_square",                    :precision => 3, :scale => 1
    t.string   "fit_filename",   :limit => 100
    t.string   "data_directory",                                                                              :null => false
    t.datetime "created_at",                                                                                  :null => false
    t.datetime "updated_at",                                                                                  :null => false
    t.string   "pdb_filename"
    t.string   "description",                                                 :default => "homolog pdb file", :null => false
  end

  create_table "submissions", :force => true do |t|
    t.string   "email",                                :default => "",   :null => false
    t.string   "data_directory",                                         :null => false
    t.integer  "editing_count",                        :default => 0,    :null => false
    t.boolean  "status",                               :default => true, :null => false
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "diagnostic_file_name"
    t.string   "diagnostic_content_type"
    t.integer  "diagnostic_file_size"
    t.string   "nomodel_file_name"
    t.string   "nomodel_content_type"
    t.integer  "nomodel_file_size"
    t.string   "bioisis_id",              :limit => 6
  end

  create_table "thumbnails", :force => true do |t|
    t.integer  "experiment_id",          :null => false
    t.string   "thumbnail_file_name"
    t.string   "thumbnail_content_type"
    t.integer  "thumbnail_file_size"
    t.datetime "thumbnail_updated_at"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
  end

  create_table "topics", :force => true do |t|
    t.integer  "forum_id"
    t.integer  "user_id"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "hits",         :default => 0
    t.integer  "sticky",       :default => 0
    t.integer  "posts_count",  :default => 0
    t.datetime "replied_at"
    t.boolean  "locked",       :default => false
    t.integer  "replied_by"
    t.integer  "last_post_id"
  end

  add_index "topics", ["forum_id", "replied_at"], :name => "index_topics_on_forum_id_and_replied_at"
  add_index "topics", ["forum_id", "sticky", "replied_at"], :name => "index_topics_on_sticky_and_replied_at"
  add_index "topics", ["forum_id"], :name => "index_topics_on_forum_id"

  create_table "users", :force => true do |t|
    t.string   "email",                                 :default => "", :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "", :null => false
    t.string   "password_salt",                         :default => "", :null => false
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "city"
    t.boolean  "mailing_list"
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "reset_password_sent_at"
  end

  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "visitors", :force => true do |t|
    t.string   "ip_address",                                     :null => false
    t.string   "coordinates"
    t.string   "description"
    t.datetime "created_at",  :default => '2007-10-04 20:28:27'
    t.datetime "updated_at",                                     :null => false
  end

end
