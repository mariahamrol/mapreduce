package org.example;

import java.io.IOException;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;

public class OrdersMapper
            extends Mapper<Object, Text, Text, Text> {

        private final Text outputKey = new Text();
        private final Text outputValue = new Text();

        @Override
        public void map(Object key, Text value, Context context)
                throws IOException, InterruptedException {

            String line = value.toString();

            // Pomijamy puste linie i nagłówek CSV
            if (line.trim().isEmpty()
                    || line.startsWith("order_id,")) {
                return;
            }

            String[] fields = line.split(",", -1);

            if (fields.length != 7) {
                return;
            }

            String restaurantId = fields[1].trim();
            String orderDate = fields[2].trim();
            String price = fields[4].trim();
            String paymentType = fields[5].trim();
            String status = fields[6].trim();

            if (orderDate.length() < 4) {
                return;
            }

            String year = orderDate.substring(0, 4);

            double totalPrice;
            try {
                totalPrice = Double.parseDouble(price);
            } catch (NumberFormatException e) {
                return;
            }

            int cancelled =
                    status.equals("Cancelled") ? 1 : 0;

            // Klucz: restaurant_id,payment_type,order_year
            outputKey.set(
                    restaurantId + "," +
                            paymentType + "," +
                            year
            );

            // Wartość: orders_count,total_price,cancelled
            outputValue.set(
                    "1," + totalPrice + "," + cancelled
            );

            context.write(outputKey, outputValue);
        }
    }