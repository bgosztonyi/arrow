# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

class TestFileWriter < Test::Unit::TestCase
  def test_write_record_batch
    tempfile = Tempfile.open("arrow-ipc-file-writer")
    output = Arrow::FileOutputStream.new(tempfile.path, false)
    begin
      field = Arrow::Field.new("enabled", Arrow::BooleanDataType.new)
      schema = Arrow::Schema.new([field])
      file_writer = Arrow::FileWriter.new(output, schema)
      begin
        record_batch = Arrow::RecordBatch.new(schema, 0, [])
        file_writer.write_record_batch(record_batch)
      ensure
        file_writer.close
      end
    ensure
      output.close
    end

    input = Arrow::MemoryMappedInputStream.new(tempfile.path)
    begin
      file_reader = Arrow::FileReader.new(input)
      assert_equal(["enabled"],
                   file_reader.schema.fields.collect(&:name))
    ensure
      input.close
    end
  end
end
