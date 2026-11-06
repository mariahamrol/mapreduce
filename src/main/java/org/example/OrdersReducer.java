package org.example;

import java.io.IOException;
import java.util.Locale;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Reducer;


public  class OrdersReducer
            extends Reducer<Text, Text, Text, Text> {

        private final Text result = new Text();

        @Override
        public void reduce(Text key, Iterable<Text> values,
                           Context context)
                throws IOException, InterruptedException {

            long ordersCount = 0;
            double totalSum = 0;
            long cancelledCount = 0;

            for (Text value : values) {
                String[] fields = value.toString().split(",");

                ordersCount += Long.parseLong(fields[0]);
                totalSum += Double.parseDouble(fields[1]);
                cancelledCount += Long.parseLong(fields[2]);
            }

            double average = totalSum / ordersCount;

            result.set(
                    ordersCount + "," +
                            String.format(Locale.US, "%.2f", average) +
                            "," + cancelledCount
            );

            context.write(key, result);
        }
    }