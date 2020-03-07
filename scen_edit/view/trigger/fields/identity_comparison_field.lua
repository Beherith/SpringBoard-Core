SB.Include(Path.Join(SB.DIRS.SRC, 'view/fields/choice_field.lua'))

IdentityComparisonField = ChoiceField:extends{}

function IdentityComparisonField:init(opts)
    opts.captions = SB.metaModel.identityComparisonTypes
    opts.items = {}
    for i = 1, #opts.captions do
        table.insert(opts.items, i)
    end

    ChoiceField.init(self, opts)
end
