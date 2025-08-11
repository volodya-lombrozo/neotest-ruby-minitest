PLENARY_DIR = misc/plenary
NEOTEST_DIR = misc/neotest
NIO_DIR = misc/nio
TREESITTER_DIR = misc/nvim-treesitter

.PHONY: deps test clean lint

deps:
	@test -d $(PLENARY_DIR) || git clone --depth=1 https://github.com/nvim-lua/plenary.nvim $(PLENARY_DIR)
	@test -d $(NEOTEST_DIR) || git clone --depth=1 https://github.com/nvim-neotest/neotest $(NEOTEST_DIR)
	@test -d $(NIO_DIR)     || git clone --depth=1 --no-single-branch https://github.com/nvim-neotest/nvim-nio $(NIO_DIR)
	@test -d $(TREESITTER_DIR) || git clone --depth=1 https://github.com/nvim-treesitter/nvim-treesitter $(TREESITTER_DIR)

test: deps
	nvim --headless --clean \
	  -u minimal_init.lua \
	  -c "PlenaryBustedDirectory tests { minimal_init = 'minimal_init.lua' }"

clean:
	rm -rf $(PLENARY_DIR)
	rm -rf $(NEOTEST_DIR)
	rm -rf $(NIO_DIR)
	rm -rf $(TREESITTER_DIR)

lint:
	luacheck .

