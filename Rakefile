require "csv"
require "rake/clean"

datasets = CSV.table "datasets.csv"

def reconstructed_from_raw sample, flat
  file1 = File.basename(sample, ".*")
  file2 = File.basename(flat, ".*")
  dir = File.dirname(sample)
  File.join(dir, "#{file1}_#{file2}.h5")
end

def png_from_row row
  File.join(["figures", "#{row[:name]}_#{row[:region]}_#{row[:smoke]}.png"])
end

def roi_from_reconstructed reconstructed
  File.join(["data", File.basename(reconstructed, ".h5") + ".npy"])
end

def csv_from_reconstructed reconstructed
  File.join(["data", File.basename(reconstructed, ".h5") + ".csv"])             
end

datasets[:reconstructed] = datasets[:sample].zip(
  datasets[:flat]).map {|s, f| reconstructed_from_raw(s, f)}
datasets[:csv] = datasets[:reconstructed].map {|f| csv_from_reconstructed(f)}
datasets[:roi] = datasets[:reconstructed].map {|f| roi_from_reconstructed(f)}
datasets[:png] = datasets.map {|f| png_from_row(f)}

datasets.each do |row|
  p row
end

namespace :figures do

  datasets.each do |row|
    desc "reconstructed figure #{row[:reconstructed]}"
    file row[:png] => ["plot_big.py", row[:reconstructed]] do |f|
      sh "python #{f.prerequisites[0]} #{f.prerequisites[1]} --big_crop 250 750 550 950 #{f.name}"
    end
  end

  desc "create all figures"
  task :all => datasets[:png]
end

namespace :reconstruction do

  datasets.each do |row|
    reconstructed = row[:reconstructed]
    CLEAN.include(reconstructed)

    desc "dpc_reconstruction of #{reconstructed}"
    file reconstructed => [row[:sample], row[:flat]] do |f|
      Dir.chdir "../dpc_reconstruction" do
        sh "dpc_radiography --drop_last --group /entry/data #{f.prerequisites.join(' ')}"
      end
    end
  end

  desc "csv with reconstructed datasets"
  file "reconstructed.csv" => datasets[:reconstructed] + ["datasets.csv"] do |f|
    File.open(f.name, "w") do |file|
      file.write(datasets.to_csv)
    end
  end
  CLOBBER.include("reconstructed.csv")

end

namespace :lung_selection do

  datasets.each do |row|

    desc "select the roi for #{row[:reconstructed]}"
    file row[:roi] => ["lung_selection.py", row[:reconstructed], "reconstructed.csv"] do |f|
      sh "python #{f.prerequisites[0]} #{f.prerequisites[1]} #{f.name}"
    end

    desc "export selection to #{row[:csv]}"
    file row[:csv] => ["lung_data.py", row[:reconstructed], row[:roi]] do |f|
      sh "python #{f.prerequisites[0]} #{f.prerequisites[1]} #{f.prerequisites[2]} #{f.name}"
    end

    CLOBBER.include(row[:roi])
    CLEAN.include(row[:csv])

  end

end

namespace :analysis do

  desc "merge the csv datasets into one table"
  file "data/pixels.rds" => ["merge_datasets.R", "reconstructed.csv"] + datasets[:csv] do |f|
    sh "./#{f.prerequisites[0]} -f #{f.prerequisites[1]} -o #{f.name}"
  end
  CLOBBER.include("data/pixels.rds")

  desc "single dataset plots"
  task "aggregated" => ["single_dataset_histogram.R", "data/pixels.rds"] do |f|
    sh "./#{f.prerequisites[0]} -f #{f.prerequisites[1]}"
  end
  CLOBBER.include("plots/ratio.png")

end

task :default => ["plots/ratio.png"]
