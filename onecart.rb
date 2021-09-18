# for 1 
Order.where(‘order_date BETWEEN ? AND ?', date_from, date_to).group(:zip_code).pluck(zip_code, count(zip_code))

# for 2
def download_response_csv
  variants_ids = params[:variant_ids]
  respond_to do |format|
  format.csv do
  send_data(
    generate_csv_data(variant_ids),
    filename: "Responses.csv"
  )
  end
end

def generate_csv_data(variant_ids)
  # builder headings
  headings = Variant.joins(:link, :shop).where(variant_id: variant_ids).group(link.platform, link.shop_name).select('link.platform, shop.shop_name').to_a.uniq.map { |t| t.join(':')}
  csv_heading = ["SKU", headings.flatten ]
  CSV.generate do |csv|
  csv << headings
    all_variants.each do |variant|
      csv << response_data(headings, variant)
    end
  end
end

def response_data(csv_heading,variant)
  result = []
  csv_heading.each do |heading|
    data = heading.split(":")
    shop_id = Shop.find(heading[1]).id
    result << Link.where('platform =? And shop_id = ?', heading[0], shop_id).variant.quantity
  end
  result
end
