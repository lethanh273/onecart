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
  # build headings
  shop_platform_headings = Variant.joins(:link, :shop).where(variant_id: variant_ids).group(link.platform, link.shop_name).select('link.platform, shop.shop_name').to_a.uniq.map { |t| t.join(':')}
  csv_headings = ["SKU", "Quantity", shop_platform_headings].flatten
  CSV.generate do |csv|
    csv << csv_headings
    variant_ids.each do |variant_id|
      csv << response_data(csv_headings, variant_id)
    end
  end
end

def response_data(csv_heading,variant_id)
  result = []
  variant = Variant.find(variant_id)
  csv_heading.each do |heading|
    data = heading.split(":")
    shop_id = Shop.find(heading[1]).id
    result << Link.where('platform =? and shop_id = ?', heading[0], shop_id).variant.quantity
  end
  quantity_sum = result.inject(0){|sum,x| sum + x }
  [variant.sku, quantity_sum, result]
end
