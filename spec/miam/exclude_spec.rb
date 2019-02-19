describe 'exclude option' do
  let(:dsl) do
    <<-RUBY
      user "bob", :path=>"/developer/" do
        login_profile :password_reset_required=>true

        groups(
          "Admin",
          "SES"
        )

        policy "S3" do
          {"Statement"=>
            [{"Action"=>
               ["s3:Get*",
                "s3:List*"],
              "Effect"=>"Allow",
              "Resource"=>"*"}]}
        end

        attached_managed_policies(
          "arn:aws:iam::aws:policy/AmazonElastiCacheReadOnlyAccess"
        )
      end

      user "mary", :path=>"/staff/" do
        policy "S3" do
          {"Statement"=>
            [{"Action"=>
               ["s3:Get*",
                "s3:List*"],
              "Effect"=>"Allow",
              "Resource"=>"*"}]}
        end

        attached_managed_policies(
          "arn:aws:iam::aws:policy/AmazonElastiCacheReadOnlyAccess"
        )
      end

      group "Admin", :path=>"/admin/" do
        policy "Admin" do
          {"Statement"=>[{"Effect"=>"Allow", "Action"=>"*", "Resource"=>"*"}]}
        end

        attached_managed_policies(
          "arn:aws:iam::aws:policy/AmazonElastiCacheReadOnlyAccess"
        )
      end

      group "SES", :path=>"/ses/" do
        policy "ses-policy" do
          {"Statement"=>
            [{"Effect"=>"Allow", "Action"=>"ses:SendRawEmail", "Resource"=>"*"}]}
        end

        attached_managed_policies(
          "arn:aws:iam::aws:policy/AmazonElastiCacheReadOnlyAccess"
        )
      end

      role "my-role", :path=>"/any/" do
        instance_profiles(
          "my-instance-profile"
        )

        assume_role_policy_document do
          {"Version"=>"2012-10-17",
           "Statement"=>
            [{"Sid"=>"",
              "Effect"=>"Allow",
              "Principal"=>{"Service"=>"ec2.amazonaws.com"},
              "Action"=>"sts:AssumeRole"}]}
        end

        policy "role-policy" do
          {"Statement"=>
            [{"Action"=>
               ["s3:Get*",
                "s3:List*"],
              "Effect"=>"Allow",
              "Resource"=>"*"}]}
        end

        attached_managed_policies(
          "arn:aws:iam::aws:policy/AmazonElastiCacheReadOnlyAccess"
        )
      end

      instance_profile "my-instance-profile", :path=>"/profile/"
    RUBY
  end

  before(:each) do
    apply { dsl }
  end

  context 'when exclude a user' do
    let(:exclude_bob) do
      <<-RUBY
      user "mary", :path=>"/staff/" do
        policy "S3" do
          {"Statement"=>
            [{"Action"=>
               ["s3:Get*",
                "s3:List*"],
              "Effect"=>"Allow",
              "Resource"=>"*"}]}
        end

        attached_managed_policies(
          "arn:aws:iam::aws:policy/AmazonElastiCacheReadOnlyAccess"
        )
      end

      group "Admin", :path=>"/admin/" do
        policy "Admin" do
          {"Statement"=>[{"Effect"=>"Allow", "Action"=>"*", "Resource"=>"*"}]}
        end

        attached_managed_policies(
          "arn:aws:iam::aws:policy/AmazonElastiCacheReadOnlyAccess"
        )
      end

      group "SES", :path=>"/ses/" do
        policy "ses-policy" do
          {"Statement"=>
            [{"Effect"=>"Allow", "Action"=>"ses:SendRawEmail", "Resource"=>"*"}]}
        end

        attached_managed_policies(
          "arn:aws:iam::aws:policy/AmazonElastiCacheReadOnlyAccess"
        )
      end

      role "my-role", :path=>"/any/" do
        instance_profiles(
          "my-instance-profile"
        )

        assume_role_policy_document do
          {"Version"=>"2012-10-17",
           "Statement"=>
            [{"Sid"=>"",
              "Effect"=>"Allow",
              "Principal"=>{"Service"=>"ec2.amazonaws.com"},
              "Action"=>"sts:AssumeRole"}]}
        end

        policy "role-policy" do
          {"Statement"=>
            [{"Action"=>
               ["s3:Get*",
                "s3:List*"],
              "Effect"=>"Allow",
              "Resource"=>"*"}]}
        end

        attached_managed_policies(
          "arn:aws:iam::aws:policy/AmazonElastiCacheReadOnlyAccess"
        )
      end

      instance_profile "my-instance-profile", :path=>"/profile/"
      RUBY
    end

    subject { client(exclude: [/bob/]) }

    it do
      updated = apply(subject) { exclude_bob }
      expect(updated).to be_falsey
    end
  end

  context 'when exclude a group, a role and an instance profile' do
    let(:exclude_admin_and_my) do
      <<-RUBY
      user "bob", :path=>"/developer/" do
        login_profile :password_reset_required=>true

        groups(
          "Admin",
          "SES"
        )

        policy "S3" do
          {"Statement"=>
            [{"Action"=>
               ["s3:Get*",
                "s3:List*"],
              "Effect"=>"Allow",
              "Resource"=>"*"}]}
        end

        attached_managed_policies(
          "arn:aws:iam::aws:policy/AmazonElastiCacheReadOnlyAccess"
        )
      end

      user "mary", :path=>"/staff/" do
        policy "S3" do
          {"Statement"=>
            [{"Action"=>
               ["s3:Get*",
                "s3:List*"],
              "Effect"=>"Allow",
              "Resource"=>"*"}]}
        end

        attached_managed_policies(
          "arn:aws:iam::aws:policy/AmazonElastiCacheReadOnlyAccess"
        )
      end

      group "SES", :path=>"/ses/" do
        policy "ses-policy" do
          {"Statement"=>
            [{"Effect"=>"Allow", "Action"=>"ses:SendRawEmail", "Resource"=>"*"}]}
        end

        attached_managed_policies(
          "arn:aws:iam::aws:policy/AmazonElastiCacheReadOnlyAccess"
        )
      end
      RUBY
    end

    subject { client(exclude: [/Admin/, /^my-/]) }

    it do
      updated = apply(subject) { exclude_admin_and_my }
      expect(updated).to be_falsey
    end
  end

  context 'when specifying exclude option in a DSL' do
    let(:exclude_everything) do
      <<-RUBY
      exclude /.*/
      RUBY
    end

    subject { client(exclude: []) }

    it do
      updated = apply(subject) { exclude_everything }
      expect(updated).to be_falsey
    end
  end
end
