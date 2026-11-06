
package org.example;

import org.apache.hadoop.conf.Configured;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.util.ToolRunner;

public class FoodOrders extends Configured implements Tool {

    public static void main(String[] args) throws Exception {
        int res = ToolRunner.run(new FoodOrders(), args);
        System.exit(res);
    }

    @Override
    public int run(String[] args) throws Exception {

        if (args.length != 2) {
            System.err.println(
                    "Usage: FoodOrders <input_dir1> <output_dir3>"
            );
            return 1;
        }

        Job job = Job.getInstance(
                getConf(), "Food Orders Statistics"
        );

        job.getConfiguration().set(
                "mapreduce.output.textoutputformat.separator", ","
        );

        job.setJarByClass(FoodOrders.class);

        FileInputFormat.addInputPath(
                job, new Path(args[0])
        );

        FileOutputFormat.setOutputPath(
                job, new Path(args[1])
        );

        job.setMapperClass(OrdersMapper.class);
        job.setReducerClass(OrdersReducer.class);

        job.setMapOutputKeyClass(Text.class);
        job.setMapOutputValueClass(Text.class);

        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(Text.class);

        return job.waitForCompletion(true) ? 0 : 1;
    }
}
