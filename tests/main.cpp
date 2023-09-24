#include "gtest/gtest.h"
#include "MiniCmakeDemoLib/core/library.h"

TEST(CoreTest, core_test) {
    EXPECT_EQ(core_test(), 123);
}

int main(int argc, char **argv) {
    testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}