describe 'update' do
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
      end

      group "Admin", :path=>"/admin/" do
        policy "Admin" do
          {"Statement"=>[{"Effect"=>"Allow", "Action"=>"*", "Resource"=>"*"}]}
        end
      end

      group "SES", :path=>"/ses/" do
        policy "ses-policy" do
          {"Statement"=>
            [{"Effect"=>"Allow", "Action"=>"ses:SendRawEmail", "Resource"=>"*"}]}
        end
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
      end

      instance_profile "my-instance-profile", :path=>"/profile/"
    RUBY
  end

  let(:expected) do
    {:users=>
      {"bob"=>
        {:path=>"/developer/",
         :groups=>["Admin", "SES"],
         :attached_managed_policies=>[],
         :policies=>
          {"S3"=>
            {"Statement"=>
              [{"Action"=>["s3:Get*", "s3:List*"],
                "Effect"=>"Allow",
                "Resource"=>"*"}]}},
         :login_profile=>{:password_reset_required=>true}},
       "mary"=>
        {:path=>"/staff/",
         :groups=>[],
         :attached_managed_policies=>[],
         :policies=>
          {"S3"=>
            {"Statement"=>
              [{"Action"=>["s3:Get*", "s3:List*"],
                "Effect"=>"Allow",
                "Resource"=>"*"}]}}}},
     :groups=>
      {"Admin"=>
        {:path=>"/admin/",
          :attached_managed_policies=>[],
         :policies=>
          {"Admin"=>
            {"Statement"=>[{"Effect"=>"Allow", "Action"=>"*", "Resource"=>"*"}]}}},
       "SES"=>
        {:path=>"/ses/",
          :attached_managed_policies=>[],
         :policies=>
          {"ses-policy"=>
            {"Statement"=>
              [{"Effect"=>"Allow",
                "Action"=>"ses:SendRawEmail",
                "Resource"=>"*"}]}}}},
     :policies => {},
     :roles=>
      {"my-role"=>
        {:path=>"/any/",
         :assume_role_policy_document=>
          {"Version"=>"2012-10-17",
           "Statement"=>
            [{"Sid"=>"",
              "Effect"=>"Allow",
              "Principal"=>{"Service"=>"ec2.amazonaws.com"},
              "Action"=>"sts:AssumeRole"}]},
         :instance_profiles=>["my-instance-profile"],
         :attached_managed_policies=>[],
         :policies=>
          {"role-policy"=>
            {"Statement"=>
              [{"Action"=>["s3:Get*", "s3:List*"],
                "Effect"=>"Allow",
                "Resource"=>"*"}]}}}},
     :instance_profiles=>{"my-instance-profile"=>{:path=>"/profile/"}}}
  end

  before(:each) do
    apply { dsl }
  end

  context 'when rename user' do
    let(:rename_user_dsl) do
      <<-RUBY
        user "bob2", :path=>"/developer/", :renamed_from=>"bob" do
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
        end

        group "Admin", :path=>"/admin/" do
          policy "Admin" do
            {"Statement"=>[{"Effect"=>"Allow", "Action"=>"*", "Resource"=>"*"}]}
          end
        end

        group "SES", :path=>"/ses/" do
          policy "ses-policy" do
            {"Statement"=>
              [{"Effect"=>"Allow", "Action"=>"ses:SendRawEmail", "Resource"=>"*"}]}
          end
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
        end

        instance_profile "my-instance-profile", :path=>"/profile/"
      RUBY
    end

    subject { client }

    it do
      updated = apply(subject) { rename_user_dsl }
      expect(updated).to be_truthy
      expected[:users]["bob2"] = expected[:users].delete("bob")
      expect(export).to eq expected
    end
  end

  context 'when rename group' do
    let(:rename_group_dsl) do
      <<-RUBY
        user "bob", :path=>"/developer/" do
          login_profile :password_reset_required=>true

          groups(
            "Admin",
            "SES2"
          )

          policy "S3" do
            {"Statement"=>
              [{"Action"=>
                 ["s3:Get*",
                  "s3:List*"],
                "Effect"=>"Allow",
                "Resource"=>"*"}]}
          end
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
        end

        group "Admin", :path=>"/admin/" do
          policy "Admin" do
            {"Statement"=>[{"Effect"=>"Allow", "Action"=>"*", "Resource"=>"*"}]}
          end
        end

        group "SES2", :path=>"/ses/", :renamed_from=>"SES2" do
          policy "ses-policy" do
            {"Statement"=>
              [{"Effect"=>"Allow", "Action"=>"ses:SendRawEmail", "Resource"=>"*"}]}
          end
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
        end

        instance_profile "my-instance-profile", :path=>"/profile/"
      RUBY
    end

    subject { client }

    it do
      updated = apply(subject) { rename_group_dsl }
      expect(updated).to be_truthy
      expected[:users]["bob"][:groups] = ["Admin", "SES2"]
      expected[:groups]["SES2"] = expected[:groups].delete("SES")
      expect(export).to eq expected
    end
  end

  context 'when rename without renamed_from' do
    let(:rename_without_renamed_from_dsl) do
      <<-RUBY
        user "bob2", :path=>"/developer/" do
          login_profile :password_reset_required=>true

          groups(
            "Admin",
            "SES2"
          )

          policy "S3" do
            {"Statement"=>
              [{"Action"=>
                 ["s3:Get*",
                  "s3:List*"],
                "Effect"=>"Allow",
                "Resource"=>"*"}]}
          end
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
        end

        group "Admin", :path=>"/admin/" do
          policy "Admin" do
            {"Statement"=>[{"Effect"=>"Allow", "Action"=>"*", "Resource"=>"*"}]}
          end
        end

        group "SES2", :path=>"/ses/" do
          policy "ses-policy" do
            {"Statement"=>
              [{"Effect"=>"Allow", "Action"=>"ses:SendRawEmail", "Resource"=>"*"}]}
          end
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
        end

        instance_profile "my-instance-profile", :path=>"/profile/"
      RUBY
    end

    subject { client }

    it do
      updated = apply(subject) { rename_without_renamed_from_dsl }
      expect(updated).to be_truthy
      expected[:users]["bob"][:groups] = ["Admin", "SES2"]
      expected[:users]["bob2"] = expected[:users].delete("bob")
      expected[:groups]["SES2"] = expected[:groups].delete("SES")
      expect(export).to eq expected
    end
  end

  context 'when rename role and instance_profile' do
    let(:rename_role_and_instance_profile_dsl) do
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
        end

        group "Admin", :path=>"/admin/" do
          policy "Admin" do
            {"Statement"=>[{"Effect"=>"Allow", "Action"=>"*", "Resource"=>"*"}]}
          end
        end

        group "SES", :path=>"/ses/" do
          policy "ses-policy" do
            {"Statement"=>
              [{"Effect"=>"Allow", "Action"=>"ses:SendRawEmail", "Resource"=>"*"}]}
          end
        end

        role "my-role2", :path=>"/any/" do
          instance_profiles(
            "my-instance-profile2"
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
        end

        instance_profile "my-instance-profile2", :path=>"/profile/"
      RUBY
    end

    subject { client }

    it do
      updated = apply(subject) { rename_role_and_instance_profile_dsl }
      expect(updated).to be_truthy
      expected[:roles]["my-role"][:instance_profiles] = ["my-instance-profile2"]
      expected[:roles]["my-role2"] = expected[:roles].delete("my-role")
      expected[:instance_profiles]["my-instance-profile2"] = expected[:instance_profiles].delete("my-instance-profile")
      expect(export).to eq expected
    end
  end
end
