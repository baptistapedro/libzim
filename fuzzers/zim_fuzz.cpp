
#include "zim/writer/contentProvider.h"
#include "zim/writer/creator.h"
#include "zim/blob.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


class TestItem : public zim::writer::Item
{
    std::string _id;
    std::string _payload;

  public:
    TestItem()  { }
    explicit TestItem(const std::string& id);
    virtual ~TestItem() = default;

    virtual std::string getPath() const;
    virtual std::string getTitle() const;
    virtual std::string getMimeType() const;

    virtual std::unique_ptr<zim::writer::ContentProvider> getContentProvider() const;
};

TestItem::TestItem(const std::string& id)
  : _id(id)
{
   _payload = id;

}

std::string TestItem::getPath() const
{
  return std::string("A/") + _id;
}

std::string TestItem::getTitle() const
{
  return _id;
}

std::string TestItem::getMimeType() const
{
  return "text/plain";
}

std::unique_ptr<zim::writer::ContentProvider> TestItem::getContentProvider() const
{
  return std::unique_ptr<zim::writer::ContentProvider>(new zim::writer::StringProvider(_payload));
}

extern "C" int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size)
{

  std::string buf(reinterpret_cast<const char*>(data), size);
  buf.push_back('\0');
  
  unsigned max = 16;
  zim::writer::Creator c;
  c.configVerbose(false).configCompression(zim::Compression::Zstd);
  c.startZimCreation("foo.zim");

  auto article = std::make_shared<TestItem>(buf.c_str());

  c.addItem(article);
  c.setMainPath("A/0");
  c.finishZimCreation();
  return 0;
}
 
